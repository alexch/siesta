require 'net/http'
require 'wrong'
include Wrong

here = File.expand_path(File.dirname(__FILE__))
$: << here

siesta_lib = "#{here}/../../lib"
$: << siesta_lib unless $:.include?(siesta_lib)
require './joe_blow'

def get(path)
  path = "/#{path}" unless path =~ /^\//
  url = URI.parse("http://#{@host}:#{@port}#{path}")
  puts "GET #{url}"
  html = Net::HTTP.get url
end

server = Siesta::Server.launch
begin
  @host = "localhost"
  @port = Siesta::Server::DEFAULT_PORT

  html = get "/"
  assert {html =~ /<title>Joe Blow: Home<\/title>/}

  html = get "/home"
  assert {html =~ /<title>Joe Blow: Home<\/title>/}

  html = get "/projects"
  assert {html =~ /<title>Joe Blow: Projects<\/title>/}

  html = get "/resume"
  assert {html =~ /<title>Joe Blow: Resume<\/title>/}

ensure
  server.stop
end
