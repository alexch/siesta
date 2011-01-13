here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta/rubric"
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
        @thing_rubric = Rubric.new(Thing)
      end

      describe Collection do
        before do
          @collection_rubric = Collection.new(Thing)
        end

        it "has a member rubric" do
          assert { @collection_rubric.member.is_a? Member }
        end

        it "s member rubric is the same as the collection's" do
          assert { @collection_rubric.member.type == Thing }
        end

        it "s member rubric has a target that's the same as the type" do
          assert { @collection_rubric.member.target == Thing }
        end

        describe '[]' do
          describe "when there's no matching rubric" do
            it "calls #find on the type" do
              found = @collection_rubric["123"]
              assert  { found }
              assert  { found.target }
              assert  { found.target.is_a? Thing }
              assert  { found.target.id == "123" }
            end

            it "makes a pseudo-proxy to the collection's member rubric" do
              # How to reliably test this?
              found = @collection_rubric["123"]
              assert { found.parts == @collection_rubric.member.parts }
            end
          end
        end
      end
    end
  end
end
