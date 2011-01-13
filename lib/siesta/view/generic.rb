require 'erector'

module Siesta
  class GenericView < Erector::Widget
    def content
      pre @resource.pretty_inspect
    end
  end
end
