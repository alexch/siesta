require 'siesta/rubric'

module Siesta
  # A Rubric whose type is a collection (e.g. an ActiveRecord class)
  class Collection < Rubric

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
      self <<(Rubric.new widget, :target => type, :name => "new") # todo: unless options[:no_new]

      @member = Member.new(type, options[:member])
    end

    def [](rubric_name)
      super or begin
        instance = begin
          type.find rubric_name
        rescue ActiveRecord::RecordNotFound
          nil
        end
        return nil if instance.nil?
        member.with_target(instance)
      end
    end
  end
end
