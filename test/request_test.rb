here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"
require "siesta/request"
require "siesta/resourceful"

module Siesta
  module RequestTest
    describe Request do
      before do
        @application = Application.new
        @request = Request.new({}, @application)
      end

      it "is a Rack::Request" do
        assert { @request.is_a? Rack::Request }
      end

      it "makes a response and preserves it" do
        response = @request.response
        assert { response.equal? @request.response }
      end

      describe '#path' do
        it 'leaves it unescaped' do
          @request.path_info = "/user/Joe+Blow"
          assert { @request.path == "/user/Joe+Blow" }
        end
      end

      describe '#path_bits' do
        it "splits and unescapes the path and returns an array" do
          @request.path_info = "/class/12/user/Joe+Blow"
          assert { @request.path_bits == ["class", "12", "user", "Joe Blow"] }
        end

        it "skips trailing slashes" do
          @request.path_info = "/class/12/"
          assert { @request.path_bits == ["class", "12"] }
        end

        # this is kind of an unintended side effect, but this is to document it
        it "skips double-slashes" do
          @request.path_info = "/class/12//user////Joe+Blow"
          assert { @request.path_bits == ["class", "12", "user", "Joe Blow"] }
        end
      end

      class Article < Struct.new(:id)
        include Siesta::Resourceful
        resourceful :collection
        property "most_popular"
        resource.member.property "title"

        def self.find(id)
          id = id.to_i
          if [123, 99].include? id
            Article.new(id)
          else
            nil
          end
        end

        def self.most_popular
          Article.new(99)
        end
      end

      describe '#targets' do

        before do
          @application << Article.resource
        end

        it "finds the root resource" do
          @request.path_info = "/"
          assert { @request.targets == [@application.root] }
        end

        it "finds the resource corresponding to a single resource" do
          @request.path_info = "/article"
          assert { @request.targets == [Article] }
        end

        it "finds the targets corresponding to the path resources" do
          @request.path_info = "/article/123"
          targets = @request.targets
          assert { targets == [Article, Article.new(123)] }
        end

        describe "for a collection" do
          it "locates the contained item" do
            @request.path_info = "/article/123"
            targets = @request.targets
            assert { targets == [Article, Article.new(123)] }
          end

          it "raises a NotFound error" do
            @request.path_info = "/article/100"
            e = rescuing do
              @request.targets
            end
            assert { e.is_a? Siesta::NotFound }
            assert { e.path == "/article/100" }
          end

          it "returns the named resource" do
            @request.path_info = "/article/most_popular"
            targets = @request.targets
            assert { targets == [Article, Article.new(99)] }
          end
        end

      end

      describe '#resources' do

        before do
          @application << Article.resource
        end

        it "finds the root resource's resource" do
          @request.path_info = "/"
          assert { @request.resources == [@application.root.resource] }
        end

        it "finds the resource for a single named top-level resource" do
          @request.path_info = "/article"
          assert { @request.resources == [
            Article.resource,
            ] }
        end

        it "finds the resource for a member resource" do
          @request.path_info = "/article/123"
          resources = @request.resources
          assert { resources[0] == Article.resource }
          assert {
            resources[1] == Article.resource.member.with_target(Article.new(123))
          }
        end

        describe "for a collection" do
          it "locates the contained item" do
            @request.path_info = "/article/123"
            resources = @request.resources
            assert { resources[0] == Article.resource }
            assert { resources[1] == Article.resource.member.with_target(Article.new(123)) }
          end

          it "raises a NotFound error" do
            @request.path_info = "/article/100"
            e = rescuing do
              @request.resources
            end
            assert { e.is_a? Siesta::NotFound }
            assert { e.path == "/article/100" }
          end

          it "returns the named resource" do
            @request.path_info = "/article/most_popular"
            resources = @request.resources
            assert { resources[0] == Article.resource }
            assert { resources[1] == Article.resource["most_popular"] }
            # perhaps Property type should be the type of the value, not the type of the object the property is on
            assert { resources[1] == Property.new(Article, :name => "most_popular") }
          end
        end

      end
    end
  end
end
