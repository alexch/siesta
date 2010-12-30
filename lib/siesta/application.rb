require 'extlib/mash'

require 'siesta/config'
require 'siesta/request'
require 'siesta/handler'

module Siesta
  class Application
    def self.instance
      @instance ||= new
    end

    def self.instance=(application)
      @instance = application
    end

    def resources
      @resources.values
    end

    def initialize
      require 'siesta/welcome_page'
      @resources = {"" => Siesta::WelcomePage}
    end

    ## A Rack application is an Ruby object (not a class) that responds to +call+...
    def call(env)
      request = Siesta::Request.new(env, self)
      handle_request(request)
      status, headers, body = request.finish
      ## ...and returns an Array of exactly three values: status, headers, body
      [status, headers, body]
    end

    # todo: test
    def handle_request(request)
      resources = request.resources
      request.resource = resources.last
      raise NotFound, request.path if request.resource.nil?
      Handler.for(request).handle
    rescue NotFound
      require 'siesta/not_found_page'
      request.response.status = 404
      # todo: different error body for JSON vs. HTML
      request.response.write NotFoundPage.new(:path => request.path).to_html
      # response.write("#{request.path} not found")
    end

    def root=(resource)
      @resources[""] = resource
    end

    def root
      self[""]
    end

    def log msg
      puts "#{Time.now} - #{msg}" if Siesta::Config.verbose
    end

    def <<(resource)
      path = strip_slashes(path_for(resource))
      if self[path]
        raise "Path #{path} already mapped" unless @resources[path] == resource
      else
        log "Registering #{path} => #{resource}"
        @resources[path] = resource
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
      @resources[strip_slashes(path)]
    end
    
    def strip_slashes(path)
      path.reverse.chomp("/").reverse.chomp("/")
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
