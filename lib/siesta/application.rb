require 'extlib/mash'

require 'siesta/config'
require 'siesta/request'
require 'siesta/handler'
require 'siesta/rubric'
require 'siesta/log'

module Siesta
  class Application < Rubric
    include Log

    # The default application is a singleton, which contains all
    # resources at the top level (plus some redundantly at lower
    # levels). But you can make one of your own if you want fewer
    # top-level resources.
    def self.default
      @instance ||= new
    end

    def self.default=(application)
      @instance = application
    end

    def initialize
      super(nil, :name => "", :target => nil)
      require 'siesta/welcome_page'
      self.root = Siesta::WelcomePage
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
      @target = resource
    end

    def root
      @target
    end

    def ==(other)
      other.is_a? Application and super
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

  end
end

if $0 == __FILE__
  require 'rack'
  require 'rack/showexceptions'
  Rack::Handler::Thin.run \
  Rack::ShowExceptions.new(Rack::Lint.new(Rack::MethodOverride.new(Siesta::Application.default))),
  :Port => 9292
end
