puts(if Object.const_defined? :RUBY_DESCRIPTION
  RUBY_DESCRIPTION
else
  "ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE} patchlevel #{RUBY_PATCHLEVEL}) [#{RUBY_PLATFORM}]"
end)

require "rubygems"
require "bundler"
Bundler.setup

here = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift "#{here}/../lib"
$LOAD_PATH.unshift "#{here}/../test"

require "minitest/spec"
require "minitest/unit"
require "wrong"
require "wrong/adapters/minitest"

include Wrong
require "spy"

require "siesta/ext"

require "siesta/config"
Siesta::Config.verbose = false

module Fixture
  class Dog
  end
end

def sys(cmd, expected_status = 0)
  start_time = Time.now
  $stderr.print cmd
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
    # in Ruby 1.8, wait_thread is nil :-( so just pretend the process was successful (status 0)
    exit_status = (wait_thread.value.exitstatus if wait_thread) || 0
    output = stdout.read + stderr.read
    unless expected_status.nil?
      assert { output and exit_status == expected_status }
    end
    yield output if block_given?
    output
  end
ensure
  $stderr.puts " (#{"%.2f" % (Time.now - start_time)} sec)"
end


MiniTest::Unit.autorun
