module Siesta
  class Config
    class << self
      attr_accessor :verbose
    end
    
    self.verbose = true
  end
end
