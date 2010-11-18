here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"
require "siesta/application"

module Siesta
  describe Application do
    before do
      @application = Application.new
    end

    describe '#root' do
      it "is Welcome To Siesta by default" do
        assert { @application.root == Siesta::WelcomeToSiesta }
      end
    end

  end
end
