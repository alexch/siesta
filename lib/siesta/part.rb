require 'siesta/application'

# todo: test
module Siesta
  class Part

    attr_reader :type # the type of resource this part describes
    attr_reader :name
    attr_reader :parts
    attr_accessor :handler_class

    def initialize(type, options = {})
      @type = type
      @name = options[:name] || type.name.split('::').last.underscore
      @parts = []
      @handler_class = options[:handler] || GenericHandler
    end

    def <<(part)
      raise ArgumentError, "Part expected but was #{part.inspect}"
      parts << part
    end

    def [](part_name)
      if parts.include? part_name
        value = type.send part_name
        Part.new(value)
      end # else nil
    end

  end

  class PropertyPart < Part
    # todo: allow a part named "foo" to call a method named "bar"

    # todo: test
    def value(object)
  	  object.send self.name
    end
  end

  # A Part whose type is a collection (e.g. an ActiveRecord class)
  class CollectionPart < Part
    attr_reader :member_part

    def initialize(type)
      super
      @member_part = MemberPart.new(type)
    end

    def [](part_name)
      super or begin
        member = type.find part_name
        raise NotFound, "#{path}/#{part_name}" if member.nil?
        member_part.with_target(member)
      end
    end
  end

  # A Part whose type is a member of a collection (e.g. an ActiveRecord instance)
  class MemberPart < Part
    attr_reader :target

    def initialize(type, options = {})
      super(type, options << {:handler => MemberHandler})
    end

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

    def with_target(target)
      proxy = dup
      proxy.instance_variable_set(:@target, target)
      proxy.instance_variable_set(:@name, proxy.target_id)
      proxy
    end
  end

end
