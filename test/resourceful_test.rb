here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"
require "siesta/resourceful"
require 'active_record'

module Siesta
  module ResourcefulTest
    describe Resourceful do
      before do
        Application.default = Application.new
      end

      after do
        Application.default = @original_instance
      end

      def app
        Siesta::Application.default
      end

      describe "when included in a class" do
        before do
          class Dog
            include Siesta::Resourceful
            resourceful
          end
        end

        # Maybe this should not actually happen? i.e. require a "resource" macro no matter what
        it "adds the class to the default application" do
          assert { app.rubrics.include? Dog.rubric }
          assert { app["/dog"] == Dog.rubric }
        end

        describe "class methods" do
          describe "#resource" do
            it "adds the class to the default application" do
              class Poodle < Dog
                resourceful
              end
              assert { app.rubrics.include? Poodle.rubric }
              assert { app["poodle"] == Poodle.rubric }
            end

            it "gives an error about duplicate paths" do
              e = rescuing do
                module Another
                  class Dog
                    include Siesta::Resourceful
                    resourceful
                  end
                end
              end
              assert { e.message == "Path /dog already mapped" }
            end

            # it "suppresses duplicate path error if it's the same resource" do
            #   e = rescuing do
            #     class Dog
            #       resourceful
            #     end
            #   end
            #   assert { e.nil? }
            # end

            it "declares rubric subresources by name" do
              class Greyhound < Dog
                resourceful
                property "color"
                property "size"
              end
              assert do
                Greyhound.rubric.rubrics == [
                  Property.new(Greyhound, :name => "color"),
                  Property.new(Greyhound, :name => "size")
                ]
              end
              assert { Dog.rubric.rubrics.empty? }
            end

            # it "declares rubric subresources by type using symbols" do
            #   # necessary for "forward declarations" in case you want to
            #   # declare the parent class before declaring the child class
            #   class SpringerSpaniel < Dog
            #     rubric :ear
            #   end
            # end

            it "declares rubric subresources for items inside collections" do
              class Whippet < Dog
                resourceful :collection
                property "reverse" # this is a property of the Whippet collection
                rubric.member.property "speed" # this is a property of each whippet item (instance)
              end
              assert do
                 Whippet.rubric.rubrics.include? Property.new(Whippet, :name => "reverse")
              end
              assert do
                 Whippet.rubric.member.rubrics.include? Property.new(Whippet, :name => "speed")
              end

            end

            it "raises an exception if you try to use member in a non-collection" do
              e = rescuing {
                class FoxTerrier < Dog
                  resourceful
                  rubric.member.property "speed"
                end
              }
              assert { e }
              assert { e.message =~ /undefined method `member'/ }
            end

            describe "flags" do
              it ":root makes the class the root resource" do
                class Pug < Dog
                  resourceful :root
                end
                assert { app.root == Pug }
                assert("the main path should work as well") { app["/pug"] == Pug.rubric }
              end

              it "marks the resource as a collection" do
                class Rotweiler < Dog
                  resourceful :collection
                end
                assert { Rotweiler.rubric.is_a? Collection }
                deny { Dog.rubric.is_a? Collection }
              end
            end

          end

          describe "#path" do
            it "contains the class name, minus its parent modules" do
              assert { Dog.path == "/dog" }
            end

            it "underscores compound class names" do
              class GreatDane < Dog
                resourceful
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

    end
  end
end
