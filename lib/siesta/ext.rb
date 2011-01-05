require 'wrong/d'

class Object
  include Wrong::D
end

class Array
  def include_only?(item)
    size == 1 && include?(item)
  end
end

class Hash
  def include_only?(item)
    size == 1 && include?(item)
  end

  alias :<< :merge  # alias shovel to merge

end

class String
  def strip_slashes
    reverse.chomp("/").reverse.chomp("/")
  end
end
