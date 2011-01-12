# todo: test
# other possible names: holder, basket, caddy, shell, casing, skin, assistant, butler, marker, guide, descriptor, rubric
# rubric - a statement of purpose or function

module Siesta
  class Rubric

    attr_reader :type # the type (class) of resource this rubric describes
    attr_reader :target # the instance (or class) of the appropriate type. Often the same as type, but not always, so be careful which one you mean.
    attr_reader :name
    attr_reader :rubrics

    def initialize(type, options = {})
      @type = type
      @name = options[:name] || type.name.split('::').last.underscore
      @target = options[:target] || type # todo: test
      @rubrics = []
    end

    def <<(rubric)
      if (rubric.is_a? String) || (rubric.is_a? Symbol)
        rubric_name = rubric
        rubric = Property.new(type, :name => rubric_name)
      elsif !rubric.is_a? Rubric
        if rubric.respond_to? :rubric
          rubric = rubric.rubric  # todo: test
        else
          # todo: Test
          raise ArgumentError, "Expected a Rubric or a Resourceful, but got #{rubric.inspect}"
        end
      end

      if part_named(rubric.name)
        raise ArgumentError, "Path /#{rubric.name} already mapped" unless part_named(rubric.name).equal?(rubric)
      else
        @rubrics << rubric
      end
    end

    def [](rubric_name)
      rubric = part_named(rubric_name)
      if rubric
        # clone the chosen rubric
        rubric = rubric.materialize(:parent_rubric => self)
      end
      rubric
    end

    def property(name, options = {})
      self << Property.new(type, :name => name)
    end

    def part_named(rubric_name)
      rubric_name = rubric_name.strip_slashes
      rubrics.detect{|p| p.name == rubric_name}
    end

    def ==(other)
      other.is_a? Rubric and
      @type == other.type and
      @name == other.name and
      @rubrics == other.rubrics
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


require 'siesta/property'
require 'siesta/collection'
require 'siesta/member'
