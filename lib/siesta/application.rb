require 'wrong/d'
require 'extlib/mash'
require 'siesta/wait_for'

class Object
  include Wrong::D
end

module Siesta
  class Application
    extend WaitFor
    
    DEFAULT_PORT = 3030

    def self.instance
      @instance ||= new
    end

    def self.instance=(new_instance)
      @instance = new_instance
    end

    def self.launch(port = DEFAULT_PORT)
      require 'rack'
      require 'rack/showexceptions'

      rack_stack = Rack::ShowExceptions.new(Rack::Lint.new(instance))
      rack_options = {:Port => port, :daemonize => true}

      launched_server = nil
      t = Thread.new do
        Rack::Handler::Thin.run rack_stack, rack_options do |server|
          launched_server = server
        end
      end
      wait_for { !launched_server.nil? } # busy polling is lame
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

    ## A Rack application is an Ruby object (not a class) that responds to +call+...
    def call(env)
      request  = Rack::Request.new(env)
      verb = request.request_method
      path = Rack::Utils.unescape(request.path_info)
      params   = Mash.new(request.params)

      response = Rack::Response.new

      process_request(request, response)
      status, headers, body = response.finish

      # Never produce a body on HEAD requests. Do retain the Content-Length
      # unless it's "0", in which case we assume it was calculated erroneously
      # for a manual HEAD response and remove it entirely.
      # (stolen from Sinatra)
      if env['REQUEST_METHOD'] == 'HEAD'
        body = []
        headers.delete('Content-Length') if headers['Content-Length'] == '0'
      end

      ## ...and returns an Array of exactly three values: status, headers, body
      [status, headers, body]
    end

    # todo: test
    def root=(resource)
      resources["/"] = resource
    end
    
    def root
      resources["/"] || begin
        require 'siesta/welcome_to_siesta'
        Siesta::WelcomeToSiesta
      end
    end

    # todo: test
    def resources
      (@resources ||= {})
    end
    
    # todo: test
    def <<(resource)
      raise "path #{resource.path} already mapped" if resources[resource.path]
      resources[resource.path] = resource
    end
    
    # todo: test
    def process_request(request, response)
      if resources.empty?      
        # todo: call route other than root
        response.write "<title>#{root.name}</title>"

        response.write <<-HTML
        <pre>
          verb=#{verb}
          path=#{path}
          params=#{params.inspect}
        </pre>
        HTML

        response.write <<-HTML
        <form method="post">
          <input type="hidden" name="_method" value="put">
          <input type="submit" value="put this">
        </form>
        HTML
      
      else
        # d { request }
        # d { request.path }
        resource = resources[request.path]
        if resource.nil?
          # todo: test 
          # todo: 404 not found
        else
          widget = resource
          response.write(widget.new.to_html)
        end
      end
    end
  end
end

if $0 == __FILE__
  require 'rack'
  require 'rack/showexceptions'
  Rack::Handler::Thin.run \
  Rack::ShowExceptions.new(Rack::Lint.new(Rack::MethodOverride.new(Siesta::Application.new))),
  :Port => 9292
end
