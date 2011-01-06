require "erector"
require "siesta/resourceful"

module Siesta
  class WelcomePage < Erector::Widgets::Page
    include Siesta::Resourceful
    resourceful
    def page_title
      "Welcome to Siesta"
    end
    def body_content
      h2 page_title
    end
  end
end
