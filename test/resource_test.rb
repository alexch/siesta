here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta/resource"
require "siesta/resourceful"

module Siesta
  module ResourceTest
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
        it "with a target" do
          assert { thing_resource.target == Thing }
        end

        it "with a default handler" do
          assert { thing_resource.handler_class == GenericHandler }
        end

        it "with a passed-in handler" do
          resource = Resource.new(Thing, :handler => WidgetHandler)
          assert { resource.handler_class == WidgetHandler }
        end
      end

      describe 'parts' do
        it "is empty at first" do
          assert { thing_resource.parts.empty? }
        end

        it "adding a string adds a resource for the part's value (method call)" do
          thing_resource << "address"
          assert { thing_resource.parts == ["address"] }
#          assert { thing_resource["address"].is_a? Resource }
#          assert { thing_resource["address"].value(Thing.new(1)) == "12 Main St." }
        end
      end

      describe '#name' do
        it "asks the target for its name, minus namespace stuff" do
          assert {thing_resource.name == "thing"}
        end
      end

      ###
      describe RepositoryResource do
        before do
          @repo_resource = RepositoryResource.new(Thing)
        end

        it "has a member resource" do
          assert { @repo_resource.member_resource.is_a? MemberResource }
        end

        it "s member resource has a parent" do
          assert { @repo_resource.member_resource.parent_resource == @repo_resource }
        end

        it "s member resource has no target (yet)" do
          assert { @repo_resource.member_resource.target.nil? }
        end

        describe '[]' do
          describe "when there's no matching part" do
            it "calls #find on the target" do
              found = @repo_resource["123"]
              assert  { found }
              assert  { found.target.is_a? Thing }
              assert  { found.target.id == "123" }
            end

            it "makes a pseudo-proxy to the repository's member resource" do
              # How to reliably test this?
              found = @repo_resource["123"]
              assert { found.parts == @repo_resource.member_resource.parts }
            end
          end
        end
      end

      ###

      describe MemberResource do
        describe 'name' do
          it "is the id of the target" do
            @repo_resource = RepositoryResource.new(Thing)
            thing_resource = @repo_resource["123"]
            assert { thing_resource.name == "123" }
          end
        end

        describe 'with_member' do
          it "creates a new instance with pointers to the old instance's data" do
            @repo_resource = RepositoryResource.new(Thing)
            master = @repo_resource.member_resource
            assert { master.target.nil? }
            thing = Thing.new(1)
            proxy = master.with_target(thing)
            assert { proxy.target.equal? thing }
            assert { proxy.parts.equal? master.parts }
            assert { proxy.parent_resource.equal? master.parent_resource }
          end
        end
      end
    end
  end
end
