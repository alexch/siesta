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

  legs = rand(1000) + 1
  post "/article", :name => "Dogs", :body => "Dogs have #{legs} legs."
  # redirects to the article page
  assert {title == "Megawiki: Dogs"}
  assert {doc.css(".main .name").text == "Dogs"}
  assert {doc.css(".main .body").text == "Dogs have #{legs} legs."}

  # get "#{path}/edit"

end
