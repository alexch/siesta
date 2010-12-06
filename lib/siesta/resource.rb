require 'siesta/application'

# 'include Siesta::Resource' if you want your class to support fun self-declarations
module Siesta
  module Resource
    def self.included(in_class)
      in_class.send(:extend, ClassMethods)
      Siesta::Application.instance << in_class
    end

    module ClassMethods
      def resource #todo: add "path" and other parameters
        Siesta::Application.instance << self
      end

      def root
        Siesta::Application.instance.root = self
      end

      def path
        Application.build_path_for(self)
      end

      def path_template
        "#{path}/:id"
      end
    end

    # instance methods
    def path
      Application.build_path_for(self)
    end
    
  end
end
