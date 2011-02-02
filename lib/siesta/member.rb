require 'siesta/resource'

module Siesta
  # A Resource whose type is a member of a collection (e.g. an ActiveRecord instance)
  class Member < Resource

    module Handler

      def handle_get(request)
        self
      end

      def handle_put(request)
        # todo: command pattern
        # todo: error handling
        # todo: status message
        update(request.params)
        request.response.redirect request.target.path
      end

      def handle_delete(request)
        # todo: command pattern
        # todo: error handling
        # todo: status message
        destroy
        collection = request.resources[-2]  # todo: test
        request.response.redirect collection.path
      end
    end

    def initialize(type, options = {})
      options ||= {}
      super
      type.send(:include, Handler)
      widget = type.const_named(:Edit) # todo: scaffoldy default
      if widget
        self <<(View.new widget, :name => "edit", :aspect => true) # todo: unless options[:no_edit]
      else
        # (raise "can't find #{type}::Edit")  # todo: 404?
        nil
      end
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

    def rename
      @name = target_id
    end

    def on_materialization(target, parent)
      super
      rename
    end
  end
end
