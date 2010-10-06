require "siesta/controller"

module Siesta
  module Resource

    def self.included(in_class)
      in_class.send(:extend, ClassMethods)
    end

    module ClassMethods
      attr_accessor :controller

      def controller
        @controller ||= Siesta::Controller.new
      end

      def get(id)
        controller.get(id)
      end

      def post(values)
        controller.post(values)
      end

      def put(id, values)
        controller.put(id, values)
      end

      def delete(id)
        controller.delete(id)
      end
    end

  end
end
