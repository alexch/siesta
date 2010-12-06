require "erector"

module Siesta
  class NotFoundPage < Erector::Widgets::Page
    def page_title
      "Not Found"
    end
    def body_content
      h2 "Not Found"
      code @path
      text " was not found"
    end
  end
end
