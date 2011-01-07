require 'siesta/application'
require 'siesta/part'

# 'include Siesta::Resourceful' if you want your class to support fun self-declarations
module Siesta
  module Resourceful
    def self.included(in_class)
      in_class.send(:extend, ClassMethods)
    end

    module ClassMethods
      def resourceful(*flags)
        options = if flags.last.is_a? Hash
          flags.pop
        else
          {}
        end

        if defined? ActiveRecord and ancestors.include?(ActiveRecord::Base) # todo: ActiveModel
          flags << :collection
        end

        if ancestors.include?(Erector::Widget)
          flags << :view
        end


        @_siesta_part = if flags.include? :collection
          CollectionPart.new(self, options)
        else
          Part.new(self, options)
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

		    Application.default << self.siesta_part
        if flags.include? :root
          Siesta::Application.default.root = self.siesta_part
        end
      end

      def collection?
        false
      end

      def part(name, options = {})
        @_siesta_part << name  # makes a sub-part. Rename?
      end

      def member_part(name)
        @_siesta_part.member_part << name
      end

      def siesta_part
        @_siesta_part
      end

      def path
        Application.build_path_for(self) # yuk
      end

    end

    # instance methods
    def path
      Application.build_path_for(self)
    end

  end
end
