require "rack"
require "active_record"

require "siesta/not_found"
require "siesta/view/generic"

module Siesta
  class Request < Rack::Request
    attr_accessor :resource, :application, :response

    def initialize(env, application)
      super(env)
      @application = application
      @response = Rack::Response.new
    end

    def params
      # todo: cache it
      Mash.new(super)
    end

    def finish
      status, headers, body = response.finish

      # Never produce a body on HEAD requests. Do retain the Content-Length
      # unless it's "0", in which case we assume it was calculated erroneously
      # for a manual HEAD response and remove it entirely.
      # (stolen from Sinatra)
      if env['REQUEST_METHOD'] == 'HEAD'
        body = []
        headers.delete('Content-Length') if headers['Content-Length'] == '0'
      end

      [status, headers, body]
    end

    def path_bits
      # should this use path_info instead?
      path.split("/").map{|part| Rack::Utils.unescape(part) unless part == ""}.compact
    end

    def parts
      bits = path_bits
      return [application.root] if bits.empty?

      parts = [application]
      current_part = application
      until bits.empty?
        bit = bits.shift
        next_part = current_part[bit]
        raise NotFound, (parts.map(&:name) << bit).join("/") if next_part.nil?
        parts << next_part
        current_part = next_part
      end
      parts
    end

    def resources
      parts.map do |part|
        if part.respond_to?(:target)
          part.target
        elsif part.respond_to?(:type)
          part.type
        else
          nil
        end
      end.compact
    end

    # A request context determines the response format, and may be used to determine which handler is chosen for a given request/resource.
    # It is usually 'json' or 'html' but could in theory be something else like 'api' or 'mobile' or 'iphone' or 'admin' depending on how an application is congfigured. I'd like to split the concept of response media format from the semantic context of why you're returning that format.
    # todo: test
    def context
      if xhr?
        'json'
      else
        'html'
      end
    end

    def verb
      verb = request_method.downcase
      if verb == "head"
        "get"
      else
        verb
      end
    end

    def handle
      result = resource.send "handle_#{verb}", self
      # todo: catch exceptions here and turn them into HTTP errors
      # todo: if redirect, use a standard view
      render result
    end

    # todo: extract renderer (takes result)

    # todo: test all cases
    def render(result)
      case context #todo: split on request.context when finding renderer? (polymorphism over switch)
        when 'html'
          # assume the view is an Erector widget for now
          response.write html(result)
        when 'json'
          response.write json(result)
        else
          raise "Unknown context #{request.context}"
      end
    end

    def html(result)
      h = if result.is_a? Erector::Widget
        result.to_html
      elsif result.is_a? Class and result.ancestors.include? Erector::Widget
        result.new({:object => resource}).to_html
      elsif result.is_a? String
        result
      elsif result.is_a? Hash
        view(result).new({:object => resource} << result).to_html
      else
        view(result).new({:object => resource, :value => result}).to_html
      end
      h
    end

    def json(result)
      hash = if (result.is_a? Hash or result.is_a? Array)
        result
      elsif result.respond_to? :serializable_hash
        result.serializable_hash
      else
        {:value => result}
      end
      hash.to_json
    end

    def view(result)
      constant_named resource.class.name + 'Page' or
      constant_named resource.class.name + 'View' or
      View::Generic
    end

    # todo: move to ext?
    def constant_named(name)
      Kernel.const_get(name)
    rescue NameError
      nil
    end

  end
end
