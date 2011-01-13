require 'siesta/application'
require 'siesta/resource'

# 'include Siesta::Resourceful' if you want your class to support fun self-declarations
module Siesta
  module Resourceful
    def self.included(in_class)
      in_class.send(:extend, ClassMethods)
    end

    def self.build(type, *args)
      type.send(:include, Resourceful)
      type.resourceful(*args)
    end

    module ClassMethods
      def resourceful(*args)
        options = if args.last.is_a? Hash
          args.pop
        else
          {}
        end
        flags = args

        if defined? ActiveRecord and ancestors.include?(ActiveRecord::Base) # todo: ActiveModel
          flags << :collection
        end

        if ancestors.include?(Erector::Widget)
          flags << :view
        end

        @_resource = (if flags.include? :collection
          Collection
        elsif flags.include? :view
          View
        else
          Resource
        end).new(self, options)

        ###
		    Application.default << @_resource
        if flags.include? :root
          Siesta::Application.default.root = self
        end
      end

      def property(name, options = {})
        resource.property(name, options)
      end

      def resource
        @_resource
      end

      def resource=(r)
        @_resource = r
      end

      def path
        Application.build_path_for(self) # yuk
      end

    end

    # instance methods
    def path
      Application.build_path_for(self)
    end

    def resource
      @resource ||= self.class.resource.member.materialize(:target => self)
    end

  end

end
