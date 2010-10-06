module Siesta
  class Controller

    attr_accessor :storage, :last_id

    def initialize
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
