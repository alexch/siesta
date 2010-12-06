# sample view-only app with top-level resources

require 'erector'
require 'siesta'

class JoeBlowPage < Erector::Widgets::Page
  external :style, <<-CSS  
  body { margin: 0;}
  .nav { float: left; border: 1px solid black; margin: .5em; padding: 1em; }
  .main { padding: 0 1em 1em 12em; }
  .header { border-bottom: 1px solid black; text-align: center; }
  .footer { clear: both; border-top: 1px solid black; text-align: center; }
  CSS
  
  def page_title
    "Joe Blow: #{super}"
  end
  
  def body_content
    h1 "I Am Joe Blow", :class => "header"
    nav
    main
    footer
  end
  
  def nav
    div :class => 'nav' do
      ul do
        li { a "Home", :href => Home.path }
        li { a "Projects", :href => Projects.path } 
        li { a "Resume", :href => Resume.path } 
      end
    end
  end
  
  def footer
    div :class => 'footer' do
      text "Copyright "
      rawtext "&copy;"
      text " 2020. Some rights reserved."
    end
  end
  
end

###########################################################################

class Home < JoeBlowPage
  include Siesta::Resource
  root
  
  def main
    div :class => 'main' do
      p "Welcome to Joe Blow's web site!"
    end
  end    
end

###########################################################################

class Projects < JoeBlowPage
  include Siesta::Resource
  
  def main
    div :class => 'main' do
      h1 "Projects"
      ul do
        li "Ruby on Snails"
        li "Toad.js"
      end
    end
  end    
end

###########################################################################

class Resume < JoeBlowPage
  include Siesta::Resource
  
  def main
    div :class => 'main' do
      h1 "Curriculum Vitae"
      h2 "Education"
      ul do
        li "University of Hard Knocks, 2000-2004"
      end
      h2 "Professional"
      ul do
        li "Bug Generator, Electronic Arcs, 2007-present"
        li "Junior Engineer, 47 1/2 Signals, 2004-2007"
      end
    end
  end    
end
