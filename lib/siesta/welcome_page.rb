require "erector"
require "siesta/resource"

module Siesta
  class WelcomePage < Erector::Widgets::Page
    include Siesta::Resource
    def page_title
      "Welcome to Siesta"
    end
    def body_content
      h2 page_title
    end
  end
end
