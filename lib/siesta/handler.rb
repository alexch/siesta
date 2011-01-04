require 'erector'

module Siesta
  # A Handler is like a Controller. It handles client requests.

  # todo: test all y'all

  class Handler

    def self.for(request)
      handler_class = request.resource.handler(request)
      handler_class.new(request)
    end

    attr_reader :request

    def initialize(request)
      @request = request
    end

    # todo: delegate with Forwardable?
    def resource
      request.resource
    end

    def response
      request.response
    end

    def params
      request.params
    end

    def verb
      verb = request.request_method.downcase
      verb = "get" if verb == "head"
      verb
    end

    def handle
      result = self.send verb
      # todo: catch exceptions here and turn them into HTTP errors
      # todo: if redirect, use a standard view
      render result
    end
    
    # todo: test all cases
    def render(result)
      case request.context #todo: split on request.context when finding handler? (polymorphism over switch)
        when 'html'
          # assume the view is an Erector widget for now
          response.write html(result)
        when 'json'
          response.write json(result)
        else
          raise "Unknown context #{request.context}"
      end
    end
    
    def html(result)
      h = if result.is_a? Erector::Widget
        result.to_html
      elsif result.is_a? Class and result.ancestors.include? Erector::Widget
        result.new({:resource => resource}).to_html
      elsif result.is_a? String
        result
      elsif result.is_a? Hash
        view(result).new({:resource => resource} << result).to_html
      else
        view(result).new({:resource => resource, :value => result}).to_html
      end
      h
    end
    
    def json(result)
      hash = if (result.is_a? Hash or result.is_a? Array)
        result
      elsif result.respond_to? :serializable_hash
        result.serializable_hash
      else
        {:value => result}
      end
      hash.to_json
    end
    
    def view(result)
      constant_named resource.class.name + 'Page' or
      constant_named resource.class.name + 'View' or
      GenericView
    end

    # todo: move to ext?
    def constant_named(name)
      Kernel.const_get(name)
    rescue NameError
      nil
    end
  end
  
  class GenericView < Erector::Widget
    def content
      pre @resource.pretty_inspect
    end
  end

  class GenericHandler < Handler
    def get
      resource
    end
  end

  class WidgetHandler < Handler    
    def get
      resource.new(params)
    end

    def post
      get
    end
  end

  class GroupHandler < Handler
    # todo: test
    def get
      resource.all
    end
    
    def post
      # todo: command pattern
      # todo: error handling
      # todo: status message
      item = resource.create(params)
      response.redirect item.path
    end
  end
  
  class MemberHandler < Handler
    
    def get
      resource
    end
    
    def put
      # todo: command pattern
      # todo: error handling
      # todo: status message
      resource.update(params)
      response.redirect resource.path
    end
    
    def delete
      # todo: command pattern
      # todo: error handling
      # todo: status message
      resource.destroy
      response.redirect collection.path
    end
    
    def collection
      self.class # override for non-ActiveRecord
    end
    
  end

end
