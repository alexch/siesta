require "siesta/resourceful"

module Siesta
  class Builder
    def self.build(type, *args)
      # options = if args.last.is_a? Hash
      #   args.pop
      # else
      #   {}
      # end
      options = {}
      flags = args

      type.send(:include, Resourceful)
      type.rubric = if flags.include? :collection
        CollectionRubric.new(type, options)
      else
        Rubric.new(type, options)
      end

    end
  end
end
