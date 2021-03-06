# sample read-write app with top-level resources
require 'bundler'
Bundler.setup

require 'erector'
require 'siesta'
require 'active_record'

here = File.expand_path(File.dirname(__FILE__))
require "#{here}/../db"

########## Megawiki Domain

# /article [GET, POST]
# /article/new [GET]
# /article/1 [GET, PUT, DELETE]
# /article/1/edit [GET]
#
class Article < ActiveRecord::Base
  include Siesta::Resourceful

  class Edit < Erector::Widget
    def content
      h1 "Edit Article"
      table do
        tr do
          th { text "id" }
          td { text @target.id }
        end
        tr do
          th { text "name" }
          td { text @target.name }
        end
        tr do
          th { text "body" }
          td { text @target.body }
        end
      end
    end
  end

  class New < Erector::Widget
    def content
      h1 "New Article"
      table do
        tr do
        end
      end
    end
  end

  resourceful :collection  # todo: lazy initialization of edit and new widget resources

end

########## Megawiki Views

# The abstract page class for all Megawiki web pages.
# Subclasses should override #main.
class MegawikiPage < Erector::Widgets::Page
  include Siesta::Resourceful
  external :style, <<-CSS
  body { margin: 0;}
  .header { border-bottom: 1px solid black; text-align: center; }
  .header h1 { margin: 0; }
  .footer { clear: both; border-top: 1px solid black; text-align: center; }
  .nav { float: left; margin: 0 .5em; padding: 1em; vertical-align: top; width: 8em; }
  .nav ul { list-style: none; }
  .main { margin-left: 8em; padding: 1em; border-left: 1px solid black; min-height: 10em; }
  .search { border: 1px solid black;}
  CSS

  needs :main_widget => nil

  def page_title
    "Megawiki: #{super}"
  end

  def body_content
    div :class => 'header' do
      h1 "Megawiki"
    end

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

  def search_box
    form :method => "get", :action => "/article" do
      table :class => "search" do
        tr do
          td do
            input :type => "text", :name => "name"
          end
          td do
            input :type => "submit"
          end
        end
      end
    end
  end
end

###########################################################################

class Home < MegawikiPage
  resourceful :root

  def main
    text "Welcome to Megawiki"
    search_box
  end
end

###########################################################################

class Article::Page < MegawikiPage
  needs :target

  def page_title
    "Megawiki: #{@target.name}"
  end

  def main
    h1 @target.name, :class => "name"
    p @target.body, :class => "body"
  end
end

######################################################

DB.create(:development)
DB.connect_to(:development)
DB.migrate
