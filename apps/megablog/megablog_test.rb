require 'net/http'
require 'wrong'
include Wrong

here = File.expand_path(File.dirname(__FILE__))
$: << here

siesta_lib = "#{here}/../../lib"
$: << siesta_lib unless $:.include?(siesta_lib)
require './activerecord_app'

server = Siesta::Application.launch
begin
  host = "localhost"
  port = Siesta::Application::DEFAULT_PORT
  url = URI.parse("http://127.0.0.1:#{port}/")
  html = Net::HTTP.get url

  assert {html =~ /<title>Megablog<\/title>/}

ensure
  server.stop
end
