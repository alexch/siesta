here = File.expand_path(File.dirname(__FILE__))
require "./test/test_helper"
require "siesta/resource"

module Siesta
  describe Controller do
    before do
      @controller = Controller.new
    end

    it "does CRUD on a transient hash" do
      # POST = create
      id = @controller.post(:meat => "ham")
      assert { id > 0 }
      assert { @controller.storage[id] == {:meat => "ham"} }

      # GET = read
      values = @controller.get(id)
      assert { values == {:meat => "ham"} }

      # PUT = update
      @controller.put(id, :meat => "spam")
      assert { @controller.storage[id] == {:meat => "spam"} }

      # DELETE = delete
      @controller.delete(id)
      assert { @controller.storage[id].nil? }
    end
  end
end
