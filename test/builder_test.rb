here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"
require "siesta/builder"

module Siesta
  module BuilderTest
    describe "#build" do
      before do
        Siesta::BuilderTest.send(:remove_const, :A) if Siesta::BuilderTest.const_defined?(:A)
        class A
        end
      end

      it "makes its parameter Resourceful" do
        Builder.build(A)
        assert { A.ancestors.include? Siesta::Resourceful }
      end

      it "gives its parameter a rubric" do
        Builder.build(A)
        assert { A.rubric }
        assert { A.rubric.is_a? Rubric }
        assert { A.rubric.type == A }
      end

      describe "with the :collection flag" do
        before do
          Builder.build(A, :collection)
        end

        it "makes a collection rubric" do
          assert { A.rubric }
          assert { A.rubric.is_a? CollectionRubric }
          assert { A.rubric.type == A }
        end

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
          assert { rubric.type == A }
          assert { rubric.target == A }
          # assert { rubric.view == ??? }
        end

        it "gives the type's instance an 'edit' part" do
          a = A.new
          rubric = a.rubric.part_named("edit")
          deny { rubric.nil? }
          assert { rubric.type == A }
          # assert { rubric.target == a }
          # assert { rubric.view == ??? }
        end

      end

    end
  end
end
