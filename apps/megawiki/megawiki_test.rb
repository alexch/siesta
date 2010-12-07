here = File.expand_path(File.dirname(__FILE__))
require "#{here}/../web_client"
require "#{here}/megawiki"

require 'fileutils'
FileUtils.rm_f("#{here}/db/development.db")

WebClient.new do
  get "/"
  assert {title == "Megawiki: Home"}

  get "/home"
  assert {title == "Megawiki: Home"}
end
