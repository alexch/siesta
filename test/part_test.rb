here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta/part"
require "siesta/resourceful"

module Siesta
  module PartTest
    describe Part do
      class Omelet
        include Siesta::Resourceful
        class << self
          attr_accessor :cheese
        end
        @cheese = "swiss"
      end

      before do
        @part = Part.new(Omelet, "cheese")
      end

      it "has a name" do
        assert { @part.name == "cheese" }
      end

      it "has a parent" do
        assert { @part.parent == Omelet }
      end

      it "parent must be a Resourceful" do
        e = rescuing do
          Part.new(Object, "cheese")
        end
        assert {e.message == Part::PARENT_MUST_BE_RESOURCE }
      end

      it "looks for a method of the part's name" do
        assert { Omelet.cheese == "swiss" }
        assert { @part.value == "swiss" }
      end

      it "can override the method name" do
        part = Part.new(Omelet, "filling", :method => "cheese")
        assert { @part.value == "swiss" }
      end        
    end
  end
end
