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

  post "/article", :name => "Dogs", :body => "Dogs are cute."

  get "/article/1"
  assert {title == "Megawiki: Dogs"}
  assert {doc.css(".main .text").text == "Dogs are cute."}

end
