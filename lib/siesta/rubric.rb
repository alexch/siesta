# todo: test
# other possible names: holder, basket, caddy, shell, casing, skin, assistant, butler, marker, guide, descriptor, rubric
# rubric - a statement of purpose or function

module Siesta
  class Rubric

    attr_reader :type # the type of resource this rubric describes (usually a class)
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
        rubric = PropertyRubric.new(type, :name => rubric_name)
      elsif !rubric.is_a? Rubric
        if rubric.respond_to? :siesta_rubric
          rubric = rubric.siesta_rubric  # todo: test
        else
          # todo: Test
          raise ArgumentError, "Expected a Rubric or a Resourceful, but got #{rubric.inspect}"
        end
      end

      if rubric_named(rubric.name)
        raise ArgumentError, "Path /#{rubric.name} already mapped" unless rubric_named(rubric.name).equal?(rubric)
      else
        @rubrics << rubric
      end
    end

    def [](rubric_name)
      rubric = rubric_named(rubric_name)
      if rubric
        # clone the chosen rubric
        rubric = rubric.materialize(:parent_rubric => self)
      end
      rubric
    end

    def rubric_named(rubric_name)
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

  class PropertyRubric < Rubric
    # todo: allow a rubric named "foo" to call a method named "bar"

    # todo: test
    def materialized(options)
      super
      value = options[:parent_rubric].target.send self.name
      @target = value
    end
  end

  # A Rubric whose type is a collection (e.g. an ActiveRecord class)
  class CollectionRubric < Rubric
    attr_reader :member_rubric

    def initialize(type, options = {})
      super
      @member_rubric = MemberRubric.new(type)
    end

    def [](rubric_name)
      super or begin
        member = begin
          type.find rubric_name
        rescue ActiveRecord::RecordNotFound
          nil
        end
        return nil if member.nil?
        member_rubric.with_target(member)
      end
    end
  end

  # A Rubric whose type is a member of a collection (e.g. an ActiveRecord instance)
  class MemberRubric < Rubric

    def path
      "#{type.path}/#{name}"
    end

    def target_id
      raise "target is nil" if target.nil?
      if target.respond_to? :id
        target.id
      else
        target.object_id
      end
    end

    def rename
      @name = target_id
    end

    def with_target(target)
      proxy = super
      proxy.rename
      proxy
    end

  end

end
