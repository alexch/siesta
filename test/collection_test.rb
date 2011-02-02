here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta/resource"
require "siesta/resourceful"

module Siesta
  module CollectionTest
    describe Collection do
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

      describe Collection do
        before do
          @collection_resource = Collection.new(Thing)
        end

        it "has a member resource" do
          assert { @collection_resource.member.is_a? Member }
        end

        it "s member resource is the same as the collection's" do
          assert { @collection_resource.member.type == Thing }
        end

        describe '[]' do
          describe "when there's no matching resource" do
            it "calls #find on the type" do
              found = @collection_resource["123"]
              assert  { found }
              assert  { found.target }
              assert  { found.target.is_a? Thing }
              assert  { found.target.id == "123" }
            end

            it "makes a pseudo-proxy to the collection's member resource" do
              # How to reliably test this?
              found = @collection_resource["123"]
              assert { found.parts == @collection_resource.member.parts }
            end
          end
        end
      end
    end
  end
end
