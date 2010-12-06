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

MiniTest::Unit.autorun
