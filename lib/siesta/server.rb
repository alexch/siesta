require 'extlib/mash'

here = File.expand_path(File.dirname(__FILE__))
lib = File.expand_path("#{here}/..")
$:<<lib unless $:.include?(lib)

require 'siesta'
require 'siesta/wait_for'
require 'siesta/ext'
require 'siesta/application'

module Siesta
  
  # This server is used mainly for testing
  class Server
    extend WaitFor
    
    DEFAULT_PORT = 3030

    def self.launch(port = DEFAULT_PORT)
      require 'rack'
      require 'rack/showexceptions'

      rack_stack = Rack::ShowExceptions.new(Rack::Lint.new(Application.default))
      rack_options = {:Port => port, :daemonize => true}

      launched_server = nil
      t = Thread.new do
        Rack::Handler::Thin.run rack_stack, rack_options do |server|
          launched_server = server
        end
      end
      wait_for { !launched_server.nil? } # busy polling is lame but necessary
      wait_for do
        begin
          url = URI.parse("http://127.0.0.1:#{port}/")
          html = Net::HTTP.get url
          true
        rescue Errno::ECONNREFUSED => e
          false
        end
      end
      puts "Launched #{launched_server.inspect}"
      launched_server
    end
  end
end
