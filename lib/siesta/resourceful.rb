require 'siesta/application'
require 'siesta/rubric'

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

        @_rubric = if flags.include? :collection
          Collection.new(self, options)
        else
          Rubric.new(self, options)
        end

        if flags.include? :view
          extend Siesta::Handler::Widget
        elsif flags.include? :collection
          extend Siesta::Handler::Collection
          include Siesta::Handler::Member
        else
          extend Siesta::Handler::Generic
          include Siesta::Handler::Generic # ???
        end

        ###
		    Application.default << @_rubric
        if flags.include? :root
          Siesta::Application.default.root = self
        end
      end

      def property(name, options = {})
        rubric.property(name, options)
      end

      def rubric
        @_rubric
      end

      def rubric=(r)
        @_rubric = r
      end

      def path
        Application.build_path_for(self) # yuk
      end

    end

    # instance methods
    def path
      Application.build_path_for(self)
    end

    def rubric
      @rubric ||= self.class.rubric.member.materialize(:target => self)
    end

  end

end
