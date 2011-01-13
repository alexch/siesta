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

      describe "#build" do
        before do
          Application.reset
          Siesta::ResourcefulTest.send(:remove_const, :A) if Siesta::ResourcefulTest.const_defined?(:A)
          class A
            class New < Erector::Widget
            end
            class Edit < Erector::Widget
            end
          end
        end

        it "makes its parameter Resourceful" do
          Resourceful.build(A)
          assert { A.ancestors.include? Siesta::Resourceful }
        end

        it "gives its parameter a rubric" do
          Resourceful.build(A)
          assert { A.rubric }
          assert { A.rubric.is_a? Rubric }
          assert { A.rubric.type == A }
        end

        describe "with the :collection flag" do
          before do
            Resourceful.build(A, :collection)
          end

          it "makes a collection rubric" do
            assert { A.rubric }
            assert { A.rubric.is_a? Collection }
            assert { A.rubric.type == A }
          end

          # todo: make these be tests of Collection

          it "makes the type's class a collection handler" do
            assert { A.is_a? Siesta::Handler::Collection }
          end

          it "makes the type's instance a member handler" do
            assert { A.new.is_a? Siesta::Handler::Member }
          end

          it "gives the type's instance a rubric" do
            a = A.new
            rubric = a.rubric
            assert { rubric }
            assert { rubric.type == A }
            assert { rubric.target == a }
          end

          it "gives the type's class a 'new' part" do
            rubric = A.rubric.part_named("new")
            deny { rubric.nil? }
            assert { rubric.type == A::New }
            assert { rubric.target == A }
          end

          it "gives the type's instance an 'edit' part" do
            a = A.new
            rubric = a.rubric.part_named("edit")
            deny { rubric.nil? }
            assert { rubric.type == A::Edit }
          end

        end

      end


      describe "when included in a base class" do
        before do
          class Dog
            include Siesta::Resourceful
          end
        end

        it "does not add the class to the default application" do
          deny { app.parts.include? Dog.rubric }
        end

        it "does not give the base class a rubric" do
          assert { Dog.rubric.nil? or Dog.rubric.parts.empty? }
        end

        describe "class methods" do
          describe "#resourceful" do
            it "adds the class to the default application" do
              class Poodle < Dog
                resourceful
              end
              assert { app.parts.include? Poodle.rubric }
              assert { app["poodle"] == Poodle.rubric }
            end

            it "gives an error about duplicate paths" do
              e = rescuing do
                module One
                  class Dog
                    include Siesta::Resourceful
                    resourceful
                  end
                end
                module Two
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
                Greyhound.rubric.parts == [
                  Property.new(Greyhound, :name => "color"),
                  Property.new(Greyhound, :name => "size")
                ]
              end
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
                 Whippet.rubric.parts.include? Property.new(Whippet, :name => "reverse")
              end
              assert do
                 Whippet.rubric.member.parts.include? Property.new(Whippet, :name => "speed")
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
