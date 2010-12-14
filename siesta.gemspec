# -*- encoding: utf-8 -*-
here = File.expand_path(File.dirname(__FILE__))
require "#{here}/lib/siesta/version.rb"

Gem::Specification.new do |s|
  s.name      = "siesta"
  s.version   = Siesta::VERSION
  s.authors   = ["Alex Chaffee"]
  s.email     = "alex@stinky.com"
  s.homepage  = "http://github.com/alexch/siesta"
  s.summary   = "Siesta takes care of the routing and lets you REST."
  s.description  = <<-EOS.strip
Got a domain object? Make it a Siesta::Resource and get a well-deserved REST.
  EOS

  s.files      = Dir['lib/**/*']
  s.test_files = Dir['test/**/*.rb']

  s.has_rdoc = true
  s.extra_rdoc_files = %w[README.md]

  s.add_dependency "extlib"

  s.add_development_dependency "wrong"

end
