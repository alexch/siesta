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

      describe '#type' do
        it "is set on construction" do
          assert { thing_resource.type == Thing }
        end
      end

      describe '#name' do
        it "by default, uses the type class name, lowercased, minus module namespace" do
          assert {thing_resource.name == "thing"}
        end

        it "can be set" do
          resource = Resource.new(Thing, :name => "stuff")
          assert {resource.name == "stuff"}
        end
      end

      describe '#parts' do
        it "is empty at first" do
          assert { thing_resource.parts.empty? }
        end
      end

      describe '#<<' do
        it "turns a string into a Property part" do
          thing_resource << "address"
          assert { thing_resource.parts.first }
          assert { thing_resource.parts.first.is_a? Property }
          assert { thing_resource.parts.first.name == "address" }
        end
      end

      describe '#target' do
        it "raises a lifecycle exception on immaterial resources" do
          e = rescuing do
            thing_resource.target
          end
          assert { e and e.is_a?(Siesta::Resource::LifecycleException) }
        end
      end

      describe '#materialized?' do
        it "is false for new resources" do
          deny { thing_resource.materialized? }
        end
      end

      describe '#materialize' do
        it "makes a shallow copy of the original resource" do
          instance = Thing.new(12)
          clone = thing_resource.materialize(instance, nil)
          assert { clone.materialized? }
          assert { clone.target == instance }
          assert { clone.parts.object_id == thing_resource.parts.object_id }
        end

        it "sets the parent" do
          class TaxonomicRank
            include Siesta::Resourceful

            attr_reader :name

            def initialize(name)
              @name = name
            end

            def create(child)
              (@children ||= {})[child.name] = child
            end

            def find(name)
              @children[name]
            end
          end

          class Kingdom < TaxonomicRank
          end

          class Phylum < TaxonomicRank
          end

          animal = Kingdom.new("animal")
          chordata = Phylum.new("chordata")

          kingdom_resource = Resource.new(Kingdom)
          phylum_resource = Resource.new(Phylum)
          kingdom_resource << phylum_resource

          material = kingdom_resource.materialize(chordata, animal)
          assert { material.materialized? }
          assert { material.parent == animal }
        end

      end

    end

    describe "an aspect" do
      it "uses the parent's target as its own" do
        alpha = Resource.new(Thing)
        beta = Resource.new(Thing, :aspect => true)
        assert { beta.aspect? }

        a = Thing.new(7)
        materialized_alpha = alpha.materialize(a, nil)
        materialized_beta = beta.materialize(beta.type, materialized_alpha)
        assert { materialized_beta.aspect? }
        assert { materialized_beta.target == a }
      end
    end

  end
end
