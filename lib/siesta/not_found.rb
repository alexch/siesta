module Siesta
  class NotFound < Exception
    attr_reader :path
    def initialize(path)
      @path = path
    end
  end
end
