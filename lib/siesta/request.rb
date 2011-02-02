require "rack"
require "active_record"

require "siesta/not_found"
require "siesta/view/generic"

module Siesta

  # I could call this a "communication" and then more cleanly encapsulate the Rack::Request, and remove the weird feeling when you say "request.response", but for now I like not having to proxy useful request methods like "params".
  class Request < Rack::Request
    attr_accessor :resource, :target, :application, :response

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

    def resources
      bits = path_bits
      return [application.root.resource.materialize(application.root, nil)] if bits.empty?

      resources = []
      current_resource = application
      processed = ""
      until bits.empty?
        bit = bits.shift
        processed << "/#{bit}"
        next_resource = current_resource[bit]
        raise NotFound, processed if next_resource.nil?
        resources << next_resource
        current_resource = next_resource
      end
      # resources.each do |r|
      #   d{r}
      # end
      resources
    end

    # A request context determines the response format, and may be used to determine which handler is chosen for a given request/target.
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
      @resource = resources.last
      @target = @resource.target
      raise NotFound, path if target.nil?
      result = target.send "handle_#{verb}", self
      # todo: catch exceptions here and turn them into HTTP errors
      # todo: if redirect, use a standard view
      render result
    rescue NotFound
      require 'siesta/not_found_page'
      response.status = 404
      # todo: different error body for JSON vs. HTML
      response.write NotFoundPage.new(:path => path).to_html
      # response.write("#{request.path} not found")
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
      html = if result.is_a? Erector::Widget
        result.to_html
      elsif result.is_a? Class and result.ancestors.include? Erector::Widget
        result.new({:target => target}).to_html
      elsif result.is_a? String
        result
      elsif result.is_a? Hash
        view(result).new({:target => target} << result).to_html
      else
        view(result).new({:target => result}).to_html
      end
      html
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
      target.class.const_named(:Page) or
      Kernel.const_named target.class.name + 'Page' or
      target.class.const_named(:View) or
      Kernel.const_named target.class.name + 'View' or
      GenericView
    end

  end
end
