# sample read-write app with top-level resources
require 'bundler'
Bundler.setup

require 'erector'
require 'siesta'
require 'active_record'

here = File.expand_path(File.dirname(__FILE__))
require "#{here}/../db"

########## Megawiki Domain

class Article < ActiveRecord::Base
  include Siesta::Resourceful
  resourceful
end

########## Megawiki Views

# The abstract page class for all Megawiki web pages.
# Subclasses should override #main.
class MegawikiPage < Erector::Widgets::Page
  include Siesta::Resourceful
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
    "Megawiki: #{super}"
  end

  def body_content
    h1 "Megawiki", :class => "header"

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
#      li { a "Create", :href => Article.path }
#      li { a "Edit", :href => Editorial.path }
#      li { a "Search", :href => Home.path }
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

class Home < MegawikiPage
  resourceful :root

  def main_content
    text "TBD"
  end
end

###########################################################################

class ArticlePage < MegawikiPage
  resourceful

  def main_content
    text "TBD"
  end
end

######################################################

DB.create(:development)
DB.connect_to(:development)
DB.migrate
