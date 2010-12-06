here = File.expand_path(File.dirname(__FILE__))
$: << here

require 'net/http'
require 'nokogiri'

siesta_lib = File.expand_path("#{here}/../lib")
$: << siesta_lib unless $:.include?(siesta_lib)
require "siesta"
require 'wrong'

class WebClient
  include Wrong

  def initialize(&block)
    @host = "localhost"
    @port = Siesta::Server::DEFAULT_PORT
    start
    begin
      instance_eval &block
    ensure
      stop
    end
  end

  def start
    @server = Siesta::Server.launch
  end

  def stop
    @server.stop
  end

  def get(path)
    path = "/#{path}" unless path =~ /^\//
    url = URI.parse("http://#{@host}:#{@port}#{path}")
    puts "GET #{url}"
    @html = Net::HTTP.get url
    @html = html[0..5000] # truncate at 5K to avoid Open3 bug
    @doc = Nokogiri::HTML(@html)
    @html
  end

  attr_reader :html, :doc, :server

  def title
    doc.xpath("/html/head/title").text
  end

end


