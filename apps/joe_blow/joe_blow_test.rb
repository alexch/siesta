here = File.expand_path(File.dirname(__FILE__))
require "#{here}/../web_client"
require "#{here}/joe_blow"

WebClient.new do
  get "/"
  assert {title == "Joe Blow: Home"}

  get "/home"
  assert {title == "Joe Blow: Home"}

  get "/projects"
  assert {title == "Joe Blow: Projects"}

  get "/resume"
  assert {title == "Joe Blow: Resume"}
end
