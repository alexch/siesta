
module Siesta
  class Resource

    module Handler
      def handle_get(request)
        self
      end

      # todo: make other handle_ methods return an 405 MethodNotAllowed HTTP error
    end

    attr_reader :type # the type (class) of object this resource describes
    attr_reader :target # the instance (or class) of the appropriate type. Often the same as type, but not always, so be careful which one you mean.
    attr_reader :name
    attr_reader :parts

    def initialize(type, options = {})
      @type = type
      @name = options[:name] || type.name.split('::').last.underscore
      @target = options[:target] || type # todo: test
      @parts = []
    end

    def <<(resource)
      if (resource.is_a? String) || (resource.is_a? Symbol)
        resource_name = resource
        resource = Property.new(type, :name => resource_name)
      elsif !resource.is_a? Resource
        if resource.respond_to? :resource
          resource = resource.resource  # todo: test
        else
          # todo: Test
          raise ArgumentError, "Expected a Resource or a Resourceful, but got #{resource.inspect}"
        end
      end

      if part_named(resource.name)
        raise ArgumentError, "Path /#{resource.name} already mapped" unless part_named(resource.name).equal?(resource)
      else
        @parts << resource
      end
    end

    def [](resource_name)
      resource = part_named(resource_name)
      if resource
        # clone the chosen resource
        resource = resource.materialize(:parent_resource => self)
      end
      resource
    end

    def property(name, options = {})
      self << Property.new(type, :name => name)
    end

    def part_named(resource_name)
      resource_name = resource_name.strip_slashes
      parts.detect{|p| p.name == resource_name}
    end

    def ==(other)
      other.is_a? Resource and
      @type == other.type and
      @name == other.name and
      @parts == other.parts
    end

    def path
      name
    end

    # todo: inline?
    def with_target(target)
      materialize(:target => target)
    end

    def materialize(options = {})
      proxy = dup
      proxy.materialized(options)
      proxy
    end

    def materialized(options = {})
      @target = options[:target] if options[:target]
      @name = options[:name] if options[:name]
    end
  end

end

# now that the base class is defined, define all the specific subclasses
require 'siesta/property'
require 'siesta/collection'
require 'siesta/member'
require 'siesta/view'
