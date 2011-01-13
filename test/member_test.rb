here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta/resource"
require "siesta/resourceful"

module Siesta
  module MemberTest
    describe Member do
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

      describe Member do
        describe 'name' do
          it "is :id" do
            @collection_resource = Collection.new(Thing)
            thing_resource = @collection_resource["123"]
            assert { thing_resource.name == "123" }
          end
        end

        describe 'with_member' do
          it "creates a new instance with pointers to the old instance's data" do
            @collection_resource = Collection.new(Thing)
            master = @collection_resource.member
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
