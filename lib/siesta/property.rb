require 'siesta/resource'

module Siesta
  class Property < Resource
    # todo: allow a resource named "foo" to call a method named "bar"

    # todo: test
    def materialized(options)
      super
      value = options[:parent_resource].target.send self.name
      @target = value
    end
  end
end
