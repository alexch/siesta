class Spy
  attr_accessor :calls

  def initialize
    @calls = []
  end

  def method_missing(*args, &block)
    args << block if block
    @calls << args
  end
end
