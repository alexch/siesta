module Resource
  def name
    
  end
  
  def child(children)
    id = children.shift
    parts[id] or find(id)
  end
  
  def parts
    @parts ||= {}
  end
  
end

module Group < Resource
  def child(children)
    id = children.shift
    parts[id] or find(id)
  end
end
