dir = File.expand_path(File.dirname(__FILE__))
$: << dir unless $:.include?(dir) # should we really have to do this?

require "rack"

module Siesta

end

require "siesta/controller"
require "siesta/resource"

