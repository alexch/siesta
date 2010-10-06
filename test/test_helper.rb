puts(if Object.const_defined? :RUBY_DESCRIPTION
  RUBY_DESCRIPTION
else
  "ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE} patchlevel #{RUBY_PATCHLEVEL}) [#{RUBY_PLATFORM}]"
end)

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

require "rubygems"
require "minitest/spec"
require "minitest/unit"
require "wrong/adapters/minitest"

include Wrong
require "./test/spy"

MiniTest::Unit.autorun
