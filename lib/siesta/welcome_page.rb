require "erector"

module Siesta
  class WelcomePage < Erector::Widgets::Page
    def page_title
      "Welcome to Siesta"
    end
    def body_content
      h2 page_title
    end
  end
end
