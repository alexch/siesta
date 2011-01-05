here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"
require "siesta/ext"

describe String do
  describe '#strip_slashes' do
    it "strips slashes from the beginning" do
      assert { "/foo".strip_slashes == "foo" }
    end
    it "strips slashes from the end" do
      assert { "/foo".strip_slashes == "foo" }
    end
    it "strips slashes from the beginning and the end" do
      assert { "/foo".strip_slashes == "foo" }
    end
    it "works on an empty string" do
      assert { "".strip_slashes == "" }
    end
    it "works on a single slash" do
      assert { "/".strip_slashes == "" }
    end
    it "leaves a normal string alone" do
      assert { "x/y".strip_slashes == "x/y" }
    end
  end
end

