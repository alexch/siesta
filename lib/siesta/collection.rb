require 'siesta/rubric'

module Siesta
  # A Rubric whose type is a collection (e.g. an ActiveRecord class)
  class Collection < Rubric
    attr_reader :member

    def initialize(type, options = {})
      super
      type.send(:extend, Siesta::Handler::Collection)
      type.send(:include, Siesta::Handler::Member)
      widget = type.const_named(:New) # todo: scaffoldy default widget
      self <<(Rubric.new widget, :target => type, :name => "new") # todo: unless options[:no_new]

      @member = Member.new(type)
      widget = type.const_named(:Edit) # todo: scaffoldy default
      @member <<(Rubric.new widget, :name => "edit") # todo: unless options[:no_edit]
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
