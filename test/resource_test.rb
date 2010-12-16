here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"
require "siesta/resource"
require 'active_record'

module Siesta
  module ResourceTest
    describe Resource do
      before do
        @original_instance = Application.instance
      end

      def app
        Siesta::Application.instance
      end

      describe "when included in a class" do
        before do
          class Dog
            include Siesta::Resource unless self.ancestors.include? Siesta::Resource
          end
        end

        # Maybe this should not actually happen? i.e. require a "resource" macro no matter what
        it "adds the class to the default application" do
          assert { app.resources.include? Dog }
          assert { app["/dog"] == Dog }
        end

        describe "class methods" do
          describe "#resource" do
            it "adds the class to the default application" do
              class Poodle < Dog
                resource
              end
              assert { app.resources.include? Poodle }
              assert { app["poodle"] == Poodle }
            end

            it "gives an error about duplicate paths" do
              e = rescuing do
                module Another
                  class Dog
                    include Siesta::Resource
                  end
                end
              end
              assert { e.message == "Path dog already mapped" }
            end

            it "suppresses duplicate path error if it's the same resource" do
              e = rescuing do
                class Dog
                  resource
                end
              end
              assert { e.nil? }
            end
            
            it "declares part subresources by name" do
              class Greyhound < Dog
                resource
                part "color"
                part "size"
              end
              assert { Greyhound.parts == ["color", "size"] }
              assert { Dog.parts.empty? }
            end

            # it "declares part subresources by type using symbols" do
            #   # necessary for "forward declarations" in case you want to 
            #   # declare the parent class before declaring the child class
            #   class SpringerSpaniel < Dog
            #     part :ear
            #   end
            # end
            
            it "declares part subresources for items inside collections" do
              class Whippet < Dog
                resource :collection
                part "reverse" # this is a part of the Whippet collection
                item_part "speed" # this is a part of each whippet item (instance)
              end
              assert { Whippet.parts == ["reverse"] }
              assert { Whippet.item_parts == ["speed"] }
            end
            
            it "raises an exception if you try to use item_part in a non-collection" do
              e = rescuing {
                class FoxTerrier < Dog
                  resource
                  item_part "speed"
                end
              }
              assert { e }
              assert { e.message == "undefined method `item_part' for Siesta::ResourceTest::FoxTerrier:Class" }
            end
            
            describe "flags" do
              it ":root makes the class the root resource" do
                class Pug < Dog
                  resource :root
                end
                assert { app.root == Pug }
                assert { app["/"] == Pug }
                assert("the main path should work as well") { app["/pug"] == Pug }
              end
              
              it "marks the resource as a collection" do
                class Rotweiler < Dog
                  resource :collection
                end
                assert { Rotweiler.collection? }
                deny { Dog.collection? }
                handler = Rotweiler.handler(Request.new({}, nil))
                assert { handler == CollectionHandler }
              end
              
              it "automatically marks an ActiveRecord object as a collection" do
                class Yorkie < ActiveRecord::Base
                  include Siesta::Resource
                  resource
                end
                assert { Yorkie.collection? }
                assert { Yorkie.handler(Request.new({}, nil)) == CollectionHandler }
              end
            end            
            
          end

          describe "#path" do
            it "contains the class name, minus its parent modules" do
              assert { Dog.path == "/dog" }
            end

            it "underscores compound class names" do
              class GreatDane < Dog
                resource
              end
              assert { GreatDane.path == "/great_dane" }
            end
          end

        end

        describe "instance methods" do
          describe "#path" do
            it "for an instance with no id method" do
              fido = Dog.new
              assert { fido.path == "/dog/#{fido.object_id}" }
            end

            it "for an instance with an id method" do
              fido = Dog.new

              def fido.id
                "fido"
              end

              assert { fido.path == "/dog/fido" }
            end
          end
        end
      end

      after do
        Application.instance = @original_instance
      end
    end
  end
end
