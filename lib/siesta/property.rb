require 'siesta/rubric'

module Siesta
  class Property < Rubric
    # todo: allow a rubric named "foo" to call a method named "bar"

    # todo: test
    def materialized(options)
      super
      value = options[:parent_rubric].target.send self.name
      @target = value
    end
  end
end
