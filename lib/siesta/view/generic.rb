require 'erector'

module Siesta
  class GenericView < Erector::Widget
    needs :target
    def content
      pre @target.pretty_inspect
    end
  end
end
