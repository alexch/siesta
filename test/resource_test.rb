dir = File.expand_path(File.dirname(__FILE__))
require "./test/test_helper"
require "siesta/resource"

module Siesta
  describe Resource do
    describe "mixed in to a plain object" do
      class Sandwich
        include Siesta::Resource
      end

      it "has a controller" do
        assert { Sandwich.controller.is_a? Siesta::Controller }
      end

      it "remembers its controller" do
        first_controller = Sandwich.controller
        second_controller = Sandwich.controller

        assert { first_controller == second_controller }
      end

      it "proxies REST methods over to the controller" do
        begin
          Sandwich.controller = Spy.new
          Sandwich.get(99) # read
          Sandwich.post(:meat => "ham") # create
          Sandwich.put(99, :meat => "spam") # update
          Sandwich.delete(99)
          assert do
            Sandwich.controller.calls == [
                    [:get, 99],
                    [:post, {:meat => "ham"}],
                    [:put, 99, {:meat => "spam"}],
                    [:delete, 99]
            ]
          end
        ensure
          Sandwich.controller = nil
        end
      end
    end
  end
end
