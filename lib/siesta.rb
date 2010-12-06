here = File.expand_path(File.dirname(__FILE__))
$: << here unless $:.include?(here) # should we really have to do this?

require "rack"
require "erector"

require "siesta/ext"  # load Siesta's extensions to core objects first

# 'include Siesta' if you want your class to support fun self-declarations
module Siesta
  def self.included(in_class)
    in_class.send(:extend, ClassMethods)
    Siesta::Application.instance << in_class
  end
  
  module ClassMethods
    def resource #todo: add "path" and other parameters
      Siesta::Application.instance << self
    end
    
    def root
      Siesta::Application.instance.root = self
    end
    
    def path
      "/#{self.name.split('::').last.underscore}" # todo: unify with Application#path_for
    end
  end
  
end

require "siesta/version"

require "siesta/server"
require "siesta/application"

