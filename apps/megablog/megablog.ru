require './megablog'
use Rack::ShowExceptions
run Siesta::Application.instance
