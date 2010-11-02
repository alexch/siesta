require 'siesta'

class Megablog
  include Siesta::Root
end

if $0 == __FILE__
  Siesta::Application.launch
end
