module Siesta
  class NotFound < Exception
    attr_reader :path
    def initialize(path)
      super
      @path = path
    end
  end
end
