require 'siesta/application'

# 'include Siesta::Resource' if you want your class to support fun self-declarations
module Siesta
  module Resource
    def self.included(in_class)
      in_class.send(:extend, ClassMethods)
      in_class.resource
    end

    module ClassMethods
      def resource(*flags) #todo: add "path" and other parameters
        Siesta::Application.instance << self
        
        if defined? ActiveRecord and ancestors.include?(ActiveRecord::Base) # todo: ActiveModel
          flags << :collection
        end
        
        if ancestors.include?(Erector::Widget)
          flags << :view
        end
        
        if flags.include? :root
          Siesta::Application.instance.root = self
        end        

        if flags.include? :collection
          self.send(:extend, CollectionMethods)
          self.send(:include, ItemMethods)
        end
        
        if flags.include? :view
          @_siesta_handler = WidgetHandler
        end
      end

      def collection?
        false
      end

      def parts
        @_siesta_parts ||= []
      end

      def part(name, options = {})
        parts << name
      end

      def path
        Application.build_path_for(self) # yuk
      end

      # todo: test
      def handler(request)
        @_siesta_handler ||= GenericHandler
      end
      
      def handler=(handler_class)
        @_siesta_handler = handler_class
      end
    end
    
    module CollectionMethods
      def item_parts
        @_siesta_item_parts ||= []
      end

      def item_part(name)
        raise "item_part can only be used for collections" unless collection?
        item_parts << name
      end
      
      def handler(request)
        @_siesta_handler ||= CollectionHandler
      end
      
      def collection?
        true
      end      
    end
    
    module ItemMethods
      def handler(request)
        @_siesta_handler ||= ItemHandler
      end
    end      

    # instance methods
    def path
      Application.build_path_for(self)
    end
    
  end
end
