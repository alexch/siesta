here = File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(here + "/..")
require "test/test_helper"

describe "sample applications" do
  apps = Dir.glob("#{here}/../apps/*").select { |path| File.directory?(path) }
  apps.each do |app|
    app_name = app.split("/").last

    it "app #{app_name}" do
      $stderr.flush
      puts "\n== Testing #{app_name}"
      $stdout.flush
      
      output = nil
      Dir.chdir(app) do
        begin
          output = sys "ruby #{app_name}_test.rb"
        rescue => e
          puts output
          raise e
        end
      end
    end
  end
end
