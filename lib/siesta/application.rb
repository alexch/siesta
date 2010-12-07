require 'extlib/mash'

require 'siesta/config'
require 'siesta/request'
require 'siesta/handler'

require 'siesta/welcome_page'
require 'siesta/not_found_page'

module Siesta
  class Application
    def self.instance
      @instance ||= new
    end

    def self.instance=(application)
      @instance = application
    end

    def resources
      @resource_paths.values
    end

    def initialize
      @resource_paths = {"/" => Siesta::WelcomePage}
    end

    ## A Rack application is an Ruby object (not a class) that responds to +call+...
    def call(env)
      request = Siesta::Request.new(env)
      handle_request(request)
      status, headers, body = request.finish
      ## ...and returns an Array of exactly three values: status, headers, body
      [status, headers, body]
    end

    # todo: test
    def handle_request(request)
      # d { request }
      # d { request.path }
      resource = self[request.path]
      if resource.nil?
        request.response.status = 404
        # todo: different error body for JSON vs. HTML
        request.response.write NotFoundPage.new(:path => request.path).to_html
        # response.write("#{request.path} not found")
      else
        request.resource = resource
        Handler.for(request).handle
      end
    end

    def root=(resource)
      @resource_paths["/"] = resource
    end

    def root
      self["/"]
    end

    def log msg
      puts "#{Time.now} - #{msg}" if Siesta::Config.verbose
    end

    def <<(resource)
      path = path_for(resource)
      if @resource_paths[path]
        raise "Path #{path} already mapped" unless @resource_paths[path] == resource
      else
        log "Registering #{path} => #{resource}"
        @resource_paths[path] = resource
      end
    end

    def self.path_for(resource)
      if resource.respond_to? :path
        resource.path
      else
        build_path_for(resource)
      end
    end

    def self.build_path_for(resource)
      if resource.is_a? Class
        "/#{resource.name.split('::').last.underscore}"
      elsif resource.respond_to? :id
        "#{path_for(resource.class)}/#{resource.id}"
      else
        "#{path_for(resource.class)}/#{resource.object_id}"
      end
    end

    # todo: Is there a cleaner way to proxy this? Maybe use Forwardable.
    def path_for(resource)
      Application.path_for(resource)
    end

    def [](path)
      @resource_paths[path]
    end

  end
end

if $0 == __FILE__
  require 'rack'
  require 'rack/showexceptions'
  Rack::Handler::Thin.run \
  Rack::ShowExceptions.new(Rack::Lint.new(Rack::MethodOverride.new(Siesta::Application.instance))),
  :Port => 9292
end
