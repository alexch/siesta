
module Siesta
  # A Handler is like a Controller. It handles client requests.

  # todo: test all y'all

  module Handler

    module Generic
      def handle_get(request)
        self
      end
    end

    module Widget
      def handle_get(request)
        new(request.params)
      end

      def handle_post(request)
        handle_get(request)
      end
    end

    module Collection
      # todo: test
      def handle_get(request)
        all
      end

      def handle_post(request)
        # todo: command pattern
        # todo: error handling
        # todo: status message
        item = create(request.params)
        request.response.redirect item.path
      end
    end

    module Member

      def handle_get(request)
        self
      end

      def handle_put(request)
        # todo: command pattern
        # todo: error handling
        # todo: status message
        update(request.params)
        request.response.redirect resource.path
      end

      def handle_delete(request)
        # todo: command pattern
        # todo: error handling
        # todo: status message
        destroy
        collection = request.rubrics[-2]  # todo: test
        request.response.redirect collection.path
      end

    end

  end
end
