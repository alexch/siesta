puts(if Object.const_defined? :RUBY_DESCRIPTION
  RUBY_DESCRIPTION
else
  "ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE} patchlevel #{RUBY_PATCHLEVEL}) [#{RUBY_PLATFORM}]"
end)

here = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift "#{here}/../lib"
$LOAD_PATH.unshift "#{here}/../test"

require "rubygems"
require "minitest/spec"
require "minitest/unit"
require "wrong/adapters/minitest"

include Wrong
require "spy"

MiniTest::Unit.autorun
