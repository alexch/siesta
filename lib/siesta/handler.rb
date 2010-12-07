module Siesta
  # A Handler is like a Controller. It handles client requests.

  # todo: test all y'all

  class Handler

    def self.for(request)
      resource = request.resource
      handler_class = if resource.ancestors.include?(Erector::Widget)
        WidgetHandler
      elsif resource.ancestors.include?(ActiveRecord::Base)
        ActiveRecordHandler
      end
      raise "Couldn't find handler for #{resource}" if handler_class.nil?
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
      self.send verb
      # todo: catch exceptions here and turn them into errors
    end

  end

  class GenericHandler < Handler
    def get
      response.write resource.inspect
    end
  end

  class WidgetHandler < Handler
    def get
      widget = resource.new(params)
      response.write widget.to_html
    end

    def post
      get
    end
  end

  class ActiveRecordHandler < Handler
    def get
#      response.write resource.find(params[:id]) # meh
    end

    def post
      @new_resource = resource.create(params)
      # todo: error handling
      response.redirect resource.path
    end
  end

end
