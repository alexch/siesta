require 'siesta/rubric'

module Siesta
  # A Rubric whose type is a member of a collection (e.g. an ActiveRecord instance)
  class Member < Rubric

    def initialize(type, options = {})
      options ||= {}
      super
      type.send(:include, Siesta::Handler::Member)
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
