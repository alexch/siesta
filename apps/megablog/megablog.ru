here = File.expand_path(File.dirname(__FILE__))
siesta_lib = File.expand_path("#{here}/../../lib")
$: << siesta_lib unless $:.include?(siesta_lib)

require './megablog'
use Rack::ShowExceptions
run Siesta::Application.instance
