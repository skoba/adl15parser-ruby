# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adl15parser/ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "adl15parser-ruby"
  spec.version       = OpenEHR::Parser::Ruby::VERSION
  spec.authors       = ["Shinji KOBAYASHI"]
  spec.email         = ["skoba@moss.gr.jp"]
  spec.summary       = %q{ADL15 Parser}
  spec.description   = %q{Parser for Archetype Definition Language ver 1.5}
  spec.homepage      = ""
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "parslet"
  spec.add_dependency 'openehr'
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
