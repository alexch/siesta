require 'erector'

module Siesta
  module View
    class Generic < Erector::Widget
      def content
        pre @resource.pretty_inspect
      end
    end
  end
end
