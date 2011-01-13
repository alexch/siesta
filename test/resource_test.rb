here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta/resource"
require "siesta/resourceful"

module Siesta
  module RubricTest
    describe Resource do
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
        @thing_resource = Resource.new(Thing)
      end

      attr_reader :thing_resource

      describe 'construction' do
        it "with a type" do
          assert { thing_resource.type == Thing }
        end

        it "with no name uses the type class name, lowercased" do
          assert {thing_resource.name == "thing"}
        end

        it "with a name" do
          resource = Resource.new(Thing, :name => "stuff")
          assert {resource.name == "stuff"}
        end
      end

      describe 'resources' do
        it "is empty at first" do
          assert { thing_resource.parts.empty? }
        end

        # it "adding a property resource for the resource's value (method call)" do
        #   thing_resource.property "address"
        #   assert { thing_resource.parts == ["address"] }
#          assert { thing_resource["address"].is_a? Resource }
#          assert { thing_resource["address"].value(Thing.new(1)) == "12 Main St." }
        # end
      end

      describe '#name' do
        it "asks the type for its name, minus namespace stuff" do
          assert {thing_resource.name == "thing"}
        end
      end
    end

  end
end
