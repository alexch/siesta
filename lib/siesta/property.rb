require 'siesta/resource'

module Siesta
  class Property < Resource
    # todo: allow a resource named "foo" to call a method named "bar"

    # todo: test
    def on_materialization(target, parent)
      super
      value = parent.target.send self.name
      @target = value
    end
  end
end
