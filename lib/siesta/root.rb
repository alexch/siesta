module Siesta
  module Root
    def self.included(into_class)
      Siesta::Application.instance.root = into_class
    end
  end
end
