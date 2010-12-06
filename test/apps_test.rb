here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

describe "sample applications" do
  it "joe_blow" do
    output = nil
    Dir.chdir("#{here}/../apps/joe_blow") do
      begin
        output = sys "ruby joe_blow_test.rb"
      rescue => e
        puts output
        raise e
      end
    end
  end
end
