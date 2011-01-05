here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta/part"
require "siesta/resourceful"

module Siesta
  module PartTest
    describe Part do
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
        @thing_part = Part.new(Thing)
      end

      attr_reader :thing_part

      describe 'construction' do
        it "with a type" do
          assert { thing_part.type == Thing }
        end

        it "with a default handler" do
          assert { thing_part.handler_class == GenericHandler }
        end

        it "with a passed-in handler" do
          part = Part.new(Thing, :handler => WidgetHandler)
          assert { part.handler_class == WidgetHandler }
        end

        it "with no name uses the type class name, lowercased" do
          assert {thing_part.name == "thing"}
        end

        it "with a name" do
          part = Part.new(Thing, :name => "stuff")
          assert {part.name == "stuff"}
        end
      end

      describe 'parts' do
        it "is empty at first" do
          assert { thing_part.parts.empty? }
        end
        #
        # it "adding a string adds a resource for the part's value (method call)" do
        #   thing_part << "address"
        #   assert { thing_part.parts == ["address"] }
#          assert { thing_part["address"].is_a? Part }
#          assert { thing_part["address"].value(Thing.new(1)) == "12 Main St." }
        # end
      end

      describe '#name' do
        it "asks the type for its name, minus namespace stuff" do
          assert {thing_part.name == "thing"}
        end
      end

      ###
      describe CollectionPart do
        before do
          @repo_part = CollectionPart.new(Thing)
        end

        it "has a member part" do
          assert { @repo_part.member_part.is_a? MemberPart }
        end

        it "s member part is the same as the collection's" do
          assert { @repo_part.member_part.type == Thing }
        end

        it "has no target (yet)" do
          assert { @repo_part.member_part.target == nil }
        end

        describe '[]' do
          describe "when there's no matching part" do
            it "calls #find on the type" do
              found = @repo_part["123"]
              assert  { found }
              assert  { found.target }
              assert  { found.target.is_a? Thing }
              assert  { found.target.id == "123" }
            end

            it "makes a pseudo-proxy to the collection's member part" do
              # How to reliably test this?
              found = @repo_part["123"]
              assert { found.parts == @repo_part.member_part.parts }
            end
          end
        end
      end

      ###

      describe MemberPart do
        describe 'name' do
          it "is :id" do
            @repo_part = CollectionPart.new(Thing)
            thing_part = @repo_part["123"]
            assert { thing_part.name == "123" }
          end
        end

        describe 'with_member' do
          it "creates a new instance with pointers to the old instance's data" do
            @repo_part = CollectionPart.new(Thing)
            master = @repo_part.member_part
            assert { master.type == Thing }
            thing = Thing.new(1)
            proxy = master.with_target(thing)
            assert { proxy.target == thing }
            assert { proxy.type == Thing }
            assert { proxy.name == 1 }
            assert { proxy.parts.equal? master.parts } # "equal?" means it's the same instance
          end
        end
      end
    end
  end
end
