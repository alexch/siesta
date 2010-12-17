here = File.expand_path(File.dirname(__FILE__))
$: << here unless $:.include?(here) # should we really have to do this?

require "rack"
require "erector"

require "siesta/ext"  # load Siesta's extensions to core objects first

require "siesta/version"

require "siesta/server"
require "siesta/application"
require "siesta/resourceful"

