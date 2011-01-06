require 'siesta/application'

# todo: test
module Siesta
  class Part

    attr_reader :type # the type of resource this part describes
    attr_reader :target # the instance (or class) of the appropriate type. Often the same as type, but not always, so be careful which one you mean.
    attr_reader :name
    attr_reader :parts

    def initialize(type, options = {})
      @type = type
      @name = options[:name] || type.name.split('::').last.underscore
      @target = options[:target] || type # todo: test
      @parts = []
    end

    def <<(part)
      if (part.is_a? String) || (part.is_a? Symbol)
        part_name = part
        part = PropertyPart.new(type, :name => part_name)
      end

      raise ArgumentError, "Part expected but was #{part.inspect}" unless part.is_a? Part
      parts << part
    end

    def [](part_name)
      part = parts.detect{|p| p.name == part_name}
      if part
        # clone the chosen part
        part = part.materialize(:parent_part => self)
      end
      part
    end

    def ==(other)
      other.is_a? Part and
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

  class PropertyPart < Part
    # todo: allow a part named "foo" to call a method named "bar"

    # todo: test
    def materialized(options)
      super
      value = options[:parent_part].target.send self.name
      @target = value
    end
  end

  # A Part whose type is a collection (e.g. an ActiveRecord class)
  class CollectionPart < Part
    attr_reader :member_part

    def initialize(type, options = {})
      super
      @member_part = MemberPart.new(type)
    end

    def [](part_name)
      super or begin
        member = begin
          type.find part_name
        rescue ActiveRecord::RecordNotFound
          nil
        end
        return nil if member.nil?
        member_part.with_target(member)
      end
    end
  end

  # A Part whose type is a member of a collection (e.g. an ActiveRecord instance)
  class MemberPart < Part

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
