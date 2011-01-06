require "rack"
require "siesta/not_found"
require "active_record"

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

  end
end
