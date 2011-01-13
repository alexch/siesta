require 'siesta/rubric'

module Siesta
  # A Rubric whose type is a member of a collection (e.g. an ActiveRecord instance)
  class Member < Rubric

    module Handler

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


    def initialize(type, options = {})
      options ||= {}
      super
      type.send(:include, Handler)
      widget = type.const_named(:Edit) # todo: scaffoldy default
      self <<(Rubric.new widget, :name => "edit") # todo: unless options[:no_edit]
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

    def with_target(target)
      proxy = super
      proxy.rename
      proxy
    end
  end
end
