
class Part
  PARENT_MUST_BE_RESOURCE = "the parent of a part must be a Siesta::Resourceful"
  
  def self.is_resource? x
    if x.is_a? Class 
      x.ancestors.include? Siesta::Resourceful
    else
      x.is_a? Siesta::Resourceful
    end
  end
  
  attr_reader :parent, :name
  
  def initialize(parent, name, options = {})    
    raise PARENT_MUST_BE_RESOURCE unless Part.is_resource? parent
    @parent = parent
    @name = name
    options = Mash.new(options)
    @method_name = options[:method] || @name
  end
  
  def value
    @parent.send(@method_name)
  end
end
