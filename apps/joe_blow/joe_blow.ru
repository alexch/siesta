here = File.expand_path(File.dirname(__FILE__))
siesta_lib = "#{here}/../../lib"
$: << siesta_lib unless $:.include?(siesta_lib)
require './joe_blow'
use Rack::ShowExceptions
run Siesta::Application.instance
