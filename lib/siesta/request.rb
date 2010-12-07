require "rack"

module Siesta
  class Request < Rack::Request
    attr_accessor :resource

    def response
      @response ||= Rack::Response.new
    end

    def path
      Rack::Utils.unescape(super)
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

  end
end
