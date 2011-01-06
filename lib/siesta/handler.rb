require 'erector'

module Siesta
  # A Handler is like a Controller. It handles client requests.

  # todo: test all y'all

  class Handler

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
      result = resource.send "handle_#{verb}", request
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
        result.new({:object => resource}).to_html
      elsif result.is_a? String
        result
      elsif result.is_a? Hash
        view(result).new({:object => resource} << result).to_html
      else
        view(result).new({:object => resource, :value => result}).to_html
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

  module GenericHandler
    def handle_get(request)
      self
    end
  end

  module WidgetHandler
    def handle_get(request)
      new(request.params)
    end

    def handle_post(request)
      handle_get(request)
    end
  end

  module CollectionHandler
    # todo: test
    def handle_get(request)
      all
    end

    def handle_post(request)
      # todo: command pattern
      # todo: error handling
      # todo: status message
      item = create(request.params)
      request.response.redirect item.path
    end
  end

  module MemberHandler

    def handle_get(request)
      self
    end

    def handle_put(request)
      # todo: command pattern
      # todo: error handling
      # todo: status message
      update(request.params)
      request.response.redirect resource.path
    end

    def handle_delete(request)
      # todo: command pattern
      # todo: error handling
      # todo: status message
      destroy
      collection = request.parts[-2]  # todo: test
      request.response.redirect collection.path
    end

  end

end
