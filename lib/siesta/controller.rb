module Siesta
  class WidgetController
    def initialize(widget_class)
      @widget_class = widget_class
    end
    
    def get(request, response)
      html = @widget_class.new.to_html
      response.write(html)
    end
  end
  
  class StorageController

    attr_accessor :storage, :last_id

    def initialize(model_class)
      @storage = {}
      @last_id = 0
    end

    def get(id)
      @storage[id]
    end

    def post(values)
      id = (@last_id += 1)
      @storage[id] = values
      id
    end

    def put(id, values)
      # todo: error if id not found
      @storage[id] = values  # todo: merge
    end

    def delete(id)
      @storage.delete(id)
    end

  end
end
