
module Siesta
  class View < Resource
    module Handler
      def handle_get(request)
        new(request.params)
      end

      def handle_post(request)
        handle_get(request)
      end
    end

    def initialize(type, options = {})
      super
      type.send(:extend, Handler)
    end
  end
end
