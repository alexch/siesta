here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta/application"
require "rack/mock"

module Siesta
  module ApplicationTest
    class Dog
    end

    describe Application do
      describe "singleton instance" do
        it "can be accessed" do
          assert { not Application.instance.nil? }
          assert { Application.instance.equal? Application.instance }
        end

        it "can be changed" do
          original_instance = Application.instance
          begin
            new_app = Application.new
            Application.instance = new_app
            assert { Application.instance == new_app }
          ensure
            Application.instance = original_instance
          end
        end
      end

      before do
        @application = Application.new
      end

      describe '#root' do
        it "is the Welcome Page by default" do
          assert { @application.root == Siesta::WelcomePage }
        end

        it "is the same as /" do
          assert { @application.root == @application["/"] }
        end
      end

      describe '#root=' do
        it "changes the root" do
          @application.root = Dog
          assert { @application.root == Dog }
          assert { @application["/"] == Dog }
        end
      end

      describe '#parts' do
        it "has only the root by default" do
          assert { @application.parts.include_only? Siesta::WelcomePage.siesta_part }
        end
      end
      
      describe '#strip_slashes' do
        it "strips slashes from the beginning" do
          assert { @application.strip_slashes("/foo") == "foo" }
        end
        it "strips slashes from the end" do
          assert { @application.strip_slashes("/foo") == "foo" }
        end
        it "strips slashes from the beginning and the end" do
          assert { @application.strip_slashes("/foo") == "foo" }
        end
        it "works on an empty string" do
          assert { @application.strip_slashes("") == "" }
        end
        it "works on a single slash" do
          assert { @application.strip_slashes("/") == "" }
        end
        it "leaves a normal string alone" do
          assert { @application.strip_slashes("x/y") == "x/y" }
        end
      end
      
      describe '#[]' do
        it "looks up a resource by name" do
          assert { @application[""] == Siesta::WelcomePage }
        end

        it "strips leading and trailing slashes" do
          assert { @application["/"] == Siesta::WelcomePage }
          @application << Part.new(Dog)
          assert { @application["/dog"] == Dog }
          assert { @application["dog/"] == Dog }
          assert { @application["/dog/"] == Dog }
        end
      end

      describe "<<" do
        it "adds a resource, using its natural path" do
          @application << Part.new(Dog)
          assert { @application["dog"] == Dog }
        end

        it "gives an error about duplicate paths" do
          @application << Part.new(Dog)
          e = rescuing do
            module Another
              class Dog
              end
            end
            @application << Another::Dog
          end
          assert { e.message == "Path /dog already mapped" }
        end

        it "suppresses duplicate path error if it's the same resource" do
          @application << Part.new(Dog)
          e = rescuing do
            @application << Part.new(Dog)
          end
          assert { e.nil? }
        end
      end

      describe "[]" do
        it "looks up a resource for the given path" do
          assert { @application[""] == Siesta::WelcomePage.siesta_part }
          assert { @application["/"] == Siesta::WelcomePage.siesta_part }
          @application << Part.new(Dog)
          assert { @application["/dog"] == Part.new(Dog) }
          assert { @application["dog"] == Part.new(Dog) }
        end
      end

      # todo: move this method to Part?
      describe "#path_for" do
        describe "returns the REST path" do
          it "for a class" do
            assert { Application.path_for(Dog) == "/dog" }
          end

          it "for an instance with no id method" do
            fido = Dog.new
            assert { Application.path_for(fido) == "/dog/#{fido.object_id}" }
          end

          it "for an instance with an id method" do
            fido = Dog.new

            def fido.id
              "fido"
            end

            assert { Application.path_for(fido) == "/dog/fido" }
          end
        end

        it "works on an instance too" do
          assert { Application.path_for(Dog) == @application.path_for(Dog) }
        end
      end

      describe '#call' do
        describe "GET" do
          it "for a missing path" do
            request = Rack::MockRequest.new(@application)
            response = request.get("/nope")
            assert { response.status == 404 }
            assert { response.body == NotFoundPage.new(:path => "/nope").to_html }
          end

          it "for an Erector widget with no params" do
            request = Rack::MockRequest.new(@application)
            response = request.get("/")
            assert { response.status == 200 }
            assert { response.body == WelcomePage.new.to_html }
          end
        end

        describe "HEAD" do
          it "returns a blank body but a valid Content-Length" do
            request = Rack::MockRequest.new(@application)
            response = request.request("HEAD", "/")
            assert { response.status == 200 }
            assert { response.body == "" }
            assert { response.headers['Content-Length'].to_i == WelcomePage.new.to_html.length }
          end
        end
      end

    end
  end
end
