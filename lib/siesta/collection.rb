require 'siesta/rubric'

module Siesta
  # A Rubric whose type is a collection (e.g. an ActiveRecord class)
  class Collection < Rubric
    attr_reader :member

    def initialize(type, options = {})
      super
      type.send(:extend, Siesta::Handler::Collection)
      type.send(:include, Siesta::Handler::Member)
      self <<(Rubric.new type, :name => "new") # todo: unless options[:no_new]

      @member = Member.new(type)
      @member <<(Rubric.new type, :name => "edit") # todo: unless options[:no_edit]
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
