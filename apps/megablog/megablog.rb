# sample view-only app with top-level resources

require 'erector'
require 'siesta'

########## Megablog Domain

class Article
  include Siesta::Resourceful
end


########## Megablog Views

# The abstract page class for all Megablog web pages.
# Subclasses should override #main.
class MegablogPage < Erector::Widgets::Page
  external :style, <<-CSS
  body { margin: 0;}
  .nav { float: left; margin: .5em; padding: 1em; }
  .nav ul { list-style: none; }
  .main { padding: 0 1em 1em 12em; border-left: 1px solid black; }
  .header { border-bottom: 1px solid black; text-align: center; }
  .footer { clear: both; border-top: 1px solid black; text-align: center; }
  CSS

  needs :main_widget => nil

  def page_title
    "Megablog: #{super}"
  end

  def body_content
    h1 "Megablog", :class => "header"

    div :class => 'nav' do
      nav
    end

    div :class => 'main' do
      main
    end

    div :class => 'footer' do
      footer
    end
  end

  def nav
    ul do
      li { a "Home", :href => Home.path }
      li { a "Archive", :href => Article.path }
      li { a "Editorial", :href => Editorial.path }
    end
  end

  def main
    text "Please override "
    code "main"
    text " in "
    code self.class.name
  end

  def footer
    p do
      text "Copyright "
      rawtext "&copy;"
      text " 2010 by Alex Chaffee."
    end
    p "Feel free to copy this site or use it as insipration for your own apps."
  end

end

###########################################################################

class Home < MegablogPage
  include Siesta::Resourceful
  resourceful :root

  def main_content
    text "TBD"
  end
end

###########################################################################

class Editorial < MegablogPage
  include Siesta::Resourceful

  def main_content
    text "TBD"
  end
end

