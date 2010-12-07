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
    @http = Net::HTTP.start(@host, @port)
  end

  def stop
    @http.finish
    @server.stop
  end

  def process_path(path)
    if path =~ /^\//
      path
    else
      "/#{path}"
    end
  end

  def url_from(path)
    URI.parse("http://#{@host}:#{@port}#{path}")
  end

  attr_reader :html, :doc, :server

  def get(path, redirects = 0)
    raise "Too many redirects to #{path}" if redirects > 3

    path = process_path(path)
    puts "GET #{url_from(path)}"

    response = @http.get path
    handle_response(response, redirects)
  end

  def post(path, params)
    path = process_path(path)
    puts "POST #{url_from(path)} #{params.inspect}"

    response = @http.post path, params.to_params
    handle_response(response)
  end

  def handle_response(response, redirects = 0)
    case response
      when Net::HTTPSuccess # 200
        @html = response.body
        @doc = Nokogiri::HTML(@html)
        @html
      when Net::HTTPRedirection # 302
        get(response['location'], redirects + 1)
      else
        puts "Error response = #{response.body.inspect}"
        response.value # Yes, it's a stupid name for a method that "Raises HTTP error if the response is not 2xx."
    end
  end

  def title
    doc.xpath("/html/head/title").text
  end

end


class Hash

  # alias shovel to merge
  alias :<< :merge

  # turns a hash into a hash
  def remap
    # This is Ruby magic for turning a hash into an array into a hash again
    Hash[*self.map do |key, value|
      yield key, value
    end.compact.flatten]
  end

  # converts a hash into CGI parameters
  #todo: test
  def to_params
    elements = []
    keys.size.times do |i|
      elements << "#{CGI::escape keys[i].to_s}=#{CGI::escape values[i].to_s}"
    end
    elements.join('&')
  end

  # converts CGI parameters into a hash
  #todo: test
  def self.from_params(params)
    result = {}
    params.split('&').each do |element|
      element = element.split('=')
      result[CGI::unescape(element[0]).to_sym] = CGI::unescape(element[1])
    end
    result
  end

end
