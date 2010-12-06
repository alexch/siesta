here = File.expand_path(File.dirname(__FILE__))
require "#{here}/../web_client"
require "#{here}/megablog"

WebClient.new do
  get "/"
  assert {title == "Megablog: Home"}

  get "/home"
  assert {title == "Megablog: Home"}
end
