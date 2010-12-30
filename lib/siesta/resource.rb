require 'siesta/application'

# todo: test
module Siesta
  class Resource

    attr_reader :target # the class or instance that this resource describes
    attr_reader :parts
    attr_accessor :handler_class
    
    def initialize(target, options = {})
      @target = target
      @parts = []
      @handler_class = options[:handler] || GenericHandler      
    end

    def <<(part_name)
      parts << part_name
    end

    def [](part_name)
      if parts.include? part_name
        value = target.send part_name
        Resource.new(value)
      end # else nil
    end

    def name
      target.name.split('::').last.underscore
    end

    def value(object)
	object.send :meh
    end

  end

  # A Resource whose target is a repository (e.g. an ActiveRecord class)
  class RepositoryResource < Resource
    attr_reader :member_resource
    
    def initialize(target)
      super
      @member_resource = MemberResource.new(self)
    end
    
    def [](part_name)
      super or begin
        member = target.find part_name
        raise NotFound, "#{path}/#{part_name}" if member.nil?
        member_resource.with_target(member)
      end
    end
  end

  # A Resource whose target is a member of a repository (e.g. an ActiveRecord instance)
  class MemberResource < Resource
    
    attr_reader :parent_resource
    
    def initialize(parent_resource)
      super(nil)
      @parent_resource = parent_resource
      @handler = ItemHandler
    end

    def path
      "#{parent_resource.path}/#{name}"
    end
    
    def name
      if target.respond_to? :id
        target.id
      else
        target.object_id
      end
    end
    
    def with_target(target)
      proxy = dup
      proxy.instance_variable_set(:@target, target)
      proxy
    end
  end

end
