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

def sys(cmd, expected_status = 0)
  start_time = Time.now
  $stdout.flush
  $stderr.print cmd
  $stderr.flush
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
    # in Ruby 1.8, wait_thread is nil :-( so just pretend the process was successful (status 0)
    exit_status = (wait_thread.value.exitstatus if wait_thread) || 0
    output = stdout.read + stderr.read
    unless expected_status.nil? or expected_status == exit_status
      raise "exit status #{exit_status} (expected #{expected_status}).\n OUTPUT:\n#{output}"
    end
    yield output if block_given?
    output
  end
ensure
  $stderr.puts " (#{"%.2f" % (Time.now - start_time)} sec)"
  $stderr.flush
end

# ARGV << "-v"  # minitest verbose

MiniTest::Unit.autorun
