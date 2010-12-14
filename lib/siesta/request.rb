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
    
    def path_parts
      # should this use path_info instead?
      path.split("/").map{|part| Rack::Utils.unescape(part) unless part == ""}.compact
    end
    
    # todo: test
    # todo: test that nil raises a NotFoundError or something
    def resources
      parts = path_parts.dup
      return [@application.root] if parts.empty?
      resources = []
      until parts.empty? 
        part = parts.shift
        resource = @application[part]
        raise NotFound, path if resource.nil?
        resources << resource
        if resource.collection? and !parts.empty?
          collection = resource
          child = parts.shift
          if collection.parts.include?(child)
            resources << collection.send(child)
          else
            begin
              item = collection.find(child)
              resources << item
              if item.nil?
                # todo: only put the parts so far into the exception
                raise NotFound, path
              end
            # todo: test
            rescue ActiveRecord::RecordNotFound
              # todo: only put the parts so far into the exception
              raise NotFound, path
            end
          end
        end
      end
      resources
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
