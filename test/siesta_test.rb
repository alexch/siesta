here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

require "siesta"

module SiestaTest
  class Dog
    include Siesta
  end

  class Pug < Dog
    resource
  end

  describe ::Siesta do
    describe "when included inside a class" do
      def app
        Siesta::Application.instance
      end
      
      it "makes that class a resource in the singleton application" do
        assert { app["/dog"] == SiestaTest::Dog }
      end
      
      it "allows subclasses to declare themselves as resources too" do
        assert { app["/pug"] == SiestaTest::Pug }
      end
    end
  end
end
