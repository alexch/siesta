require 'extlib/mash'

require 'siesta/config'
require 'siesta/request'
require 'siesta/handler'
require 'siesta/part'

module Siesta
  class Application < Part

    # The default application is a singleton, but you can make one of your own if you want
    def self.default
      @instance ||= new
    end

    def self.default=(application)
      @instance = application
    end

    def parts
      @parts.values
    end

    def initialize
      require 'siesta/welcome_page'
      @parts = {"" => Part.new(Siesta::WelcomePage)}
    end

    ## A Rack application is a Ruby object (not a class) that responds to +call+...
    def call(env)
      request = Siesta::Request.new(env, self)
      request.handle
      status, headers, body = request.finish
      ## ...and returns an Array of exactly three values: status, headers, body
      [status, headers, body]
    end

    def root=(resource)
      @parts[""] = resource
    end

    def root
      self[""]
    end

    def name
      ""
    end

    def target
      nil
    end

    def type
      nil
    end

    def log msg
      puts "#{Time.now} - #{msg}" if Siesta::Config.verbose
    end

    def <<(part)
      path = part.name
      if self[path]
        raise "Path #{path} already mapped" unless @parts[path] == part
      else
        log "Registering #{path} => #{part.type}"
        @parts[path] = part
      end
    end

    def ==(other)
      other.is_a? Application and
      other.instance_variable_get(:@parts) == @parts
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
      @parts[strip_slashes(path)]
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
  Rack::ShowExceptions.new(Rack::Lint.new(Rack::MethodOverride.new(Siesta::Application.default))),
  :Port => 9292
end
