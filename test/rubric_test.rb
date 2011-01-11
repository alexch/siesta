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
          assert { thing_rubric.rubrics.empty? }
        end
        #
        # it "adding a string adds a resource for the rubric's value (method call)" do
        #   thing_rubric << "address"
        #   assert { thing_rubric.rubrics == ["address"] }
#          assert { thing_rubric["address"].is_a? Rubric }
#          assert { thing_rubric["address"].value(Thing.new(1)) == "12 Main St." }
        # end
      end

      describe '#name' do
        it "asks the type for its name, minus namespace stuff" do
          assert {thing_rubric.name == "thing"}
        end
      end

      ###
      describe CollectionRubric do
        before do
          @collection_rubric = CollectionRubric.new(Thing)
        end

        it "has a member rubric" do
          assert { @collection_rubric.member.is_a? MemberRubric }
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
              assert { found.rubrics == @collection_rubric.member.rubrics }
            end
          end
        end
      end

      ###

      describe MemberRubric do
        describe 'name' do
          it "is :id" do
            @collection_rubric = CollectionRubric.new(Thing)
            thing_rubric = @collection_rubric["123"]
            assert { thing_rubric.name == "123" }
          end
        end

        describe 'with_member' do
          it "creates a new instance with pointers to the old instance's data" do
            @collection_rubric = CollectionRubric.new(Thing)
            master = @collection_rubric.member
            assert { master.type == Thing }
            thing = Thing.new(1)
            proxy = master.with_target(thing)
            assert { proxy.target == thing }
            assert { proxy.type == Thing }
            assert { proxy.name == 1 }
            assert { proxy.rubrics.equal? master.rubrics } # "equal?" means it's the same instance
          end
        end
      end
    end
  end
end
