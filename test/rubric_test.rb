here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta/rubric"
require "siesta/resourceful"

module Siesta
  module RubricTest
    describe Rubric do
      class Thing
        include Siesta::Resourceful

        def self.find(id)
          case id
          when :nil
            nil
          when :not_found
            raise NotFound
          else
            Thing.new(id)
          end
        end

        attr_reader :id

        def initialize(id)
          @id = id
        end

        def address
          "12 Main St."
        end

      end

      before do
        @thing_rubric = Rubric.new(Thing)
      end

      attr_reader :thing_rubric

      describe 'construction' do
        it "with a type" do
          assert { thing_rubric.type == Thing }
        end

        it "with no name uses the type class name, lowercased" do
          assert {thing_rubric.name == "thing"}
        end

        it "with a name" do
          rubric = Rubric.new(Thing, :name => "stuff")
          assert {rubric.name == "stuff"}
        end
      end

      describe 'rubrics' do
        it "is empty at first" do
          assert { thing_rubric.parts.empty? }
        end

        # it "adding a property resource for the rubric's value (method call)" do
        #   thing_rubric.property "address"
        #   assert { thing_rubric.parts == ["address"] }
#          assert { thing_rubric["address"].is_a? Rubric }
#          assert { thing_rubric["address"].value(Thing.new(1)) == "12 Main St." }
        # end
      end

      describe '#name' do
        it "asks the type for its name, minus namespace stuff" do
          assert {thing_rubric.name == "thing"}
        end
      end
    end

  end
end
