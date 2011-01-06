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
        part "most_popular"
        member_part "title"

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

      describe '#resources' do

        before do
          @application << Article.siesta_part
        end

        it "finds the root resource" do
          @request.path_info = "/"
          assert { @request.resources == [@application.root.target] }
        end

        it "finds the resource corresponding to a single part" do
          @request.path_info = "/article"
          assert { @request.resources == [Article] }
        end

        it "finds the resources corresponding to the path parts" do
          @request.path_info = "/article/123"
          resources = @request.resources
          assert { resources == [Article, Article.new(123)] }
        end

        describe "for a collection" do
          it "locates the contained item" do
            @request.path_info = "/article/123"
            resources = @request.resources
            assert { resources == [Article, Article.new(123)] }
          end

          it "raises a NotFound error" do
            @request.path_info = "/article/100"
            e = rescuing do
              @request.resources
            end
            assert { e.is_a? Siesta::NotFound }
            assert { e.path == "/article/100" }
          end

          it "returns the named part" do
            @request.path_info = "/article/most_popular"
            resources = @request.resources
            assert { resources == [Article, Article.new(99)] }
          end
        end

      end

      describe '#parts' do

        before do
          @application << Article.siesta_part
        end

        it "finds the root resource" do
          @request.path_info = "/"
          assert { @request.parts == [@application.root] }
        end

        it "finds the part for a single named top-level resource" do
          @request.path_info = "/article"
          assert { @request.parts == [
            @application,
            Article.siesta_part,
            ] }
        end

        it "finds the part for a member resource" do
          @request.path_info = "/article/123"
          parts = @request.parts
          assert { parts[0].equal? @application }
          assert { parts[1] == Article.siesta_part }
          assert {
            parts[2] == Article.siesta_part.member_part.with_target(Article.new(123))
          }
        end

        describe "for a collection" do
          it "locates the contained item" do
            @request.path_info = "/article/123"
            parts = @request.parts
            assert { parts[0].equal? @application }
            assert { parts[1] == Article.siesta_part }
            assert { parts[2] == Article.siesta_part.member_part.with_target(Article.new(123)) }
          end

          it "raises a NotFound error" do
            @request.path_info = "/article/100"
            e = rescuing do
              @request.parts
            end
            assert { e.is_a? Siesta::NotFound }
            assert { e.path == "/article/100" }
          end

          it "returns the named part" do
            @request.path_info = "/article/most_popular"
            parts = @request.parts
            assert { parts[0].equal? @application }
            assert { parts[1] == Article.siesta_part }
            assert { parts[2] == Article.siesta_part["most_popular"] }
            # perhaps PropertyPart type should be the type of the value, not the type of the object the property is on
            assert { parts[2] == PropertyPart.new(Article, :name => "most_popular") }
          end
        end

      end
    end
  end
end
