require 'siesta/resource'

module Siesta
  # A Resource whose type is a collection (e.g. an ActiveRecord class)
  class Collection < Resource

    module Handler
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

    attr_reader :member

    def initialize(type, options = {})
      super
      type.send(:extend, Handler)
      widget = type.const_named(:New) # todo: scaffoldy default widget
      self <<(View.new widget, :aspect => true, :name => "new") # todo: unless options[:no_new]

      @member = Member.new(type, options[:member])
    end

    def [](resource_name)
      part = super
      part or begin
        instance = begin
          type.find resource_name
        rescue ActiveRecord::RecordNotFound
          nil
        end
        return nil if instance.nil?
        member.materialize(instance, self)
      end
    end
  end
end
