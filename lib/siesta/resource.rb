require "siesta/controller"
require "siesta/application"

module Siesta
  module Resource

    def self.included(in_class)
      in_class.send(:extend, ClassMethods)
      Siesta::Application.instance << in_class
      in_class.controller_class = if in_class.ancestors.include? Erector::Widget
        Siesta::WidgetController
      else
        Siesta::StorageController
      end        
      # d { in_class.controller_class }
    end

    module ClassMethods
      def controller_class=(controller_class)
        @controller_class = controller_class
      end
      
      attr_reader :controller_class
      
      def controller
        @controller_class.new(self)
      end
      
      def path
        "/" + self.name.split('::').last.downcase
      end

      # def get(id)
      #   controller.get(id)
      # end
      # 
      # def post(values)
      #   controller.post(values)
      # end
      # 
      # def put(id, values)
      #   controller.put(id, values)
      # end
      # 
      # def delete(id)
      #   controller.delete(id)
      # end
    end

  end
end
