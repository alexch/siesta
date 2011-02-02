
module Siesta
  class Resource

    module Handler
      def handle_get(request)
        self
      end

      # todo: make other handle_ methods return an 405 MethodNotAllowed HTTP error
    end

    class LifecycleException < Exception
    end

    attr_reader :type # the type (class) of object this resource describes
    attr_reader :name
    attr_reader :parts

    def initialize(type, options = {})
      @type = type
      @name = options[:name] || type.name.split('::').last.underscore
      @aspect = true if options[:aspect]
      @parts = []
    end

    # the instance (or class) of the appropriate type. Only available on materialized resources.
    def target
      @target or raise LifecycleException.new("can't call target until you materialize the resource")
    end

    # the instance (or class) of the appropriate type. Only available on materialized resources.
    def parent
      @parent or raise LifecycleException.new("can't call parent until you materialize the resource")
    end

    def aspect?
      @aspect
    end

    def <<(part)
      if (part.is_a? String) || (part.is_a? Symbol)
        part_name = part
        part = Property.new(type, :name => part_name)
      elsif !part.is_a? Resource
        if part.respond_to? :resource
          part = part.resource  # todo: test
        else
          # todo: Test
          raise ArgumentError, "Expected a Resource or a Resourceful or a Property name, but got #{part.inspect}"
        end
      end

      add_part(part)
    end

    def add_part(resource)
      if part_named(resource.name)
        raise ArgumentError, "Path /#{resource.name} already mapped" unless part_named(resource.name).equal?(resource)
      else
        @parts << resource
      end
    end

    def [](resource_name)
      part = part_named(resource_name)
      if part
        # clone the chosen resource
        part.materialize(part.type, self) # why part.type?
      end
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

    # to materialize a resource is to attach it to an instance, rather than a type.
    # This method makes a duplicate
    def materialize(target, parent)
      clone = dup
      clone.on_materialization(target, parent)
      clone
    end

    def materialized?
      @target
    end

    def on_materialization(target, parent)
      @target = aspect? ? parent.target : target
      @parent = parent
    end
  end

end

# now that the base class is defined, define all the specific subclasses
require 'siesta/property'
require 'siesta/collection'
require 'siesta/member'
require 'siesta/view'
