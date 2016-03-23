# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logstash/mass_effect/version'

Gem::Specification.new do |spec|
  spec.name          = "logstash-mass_effect"
  spec.version       = Logstash::MassEffect::VERSION
  spec.authors       = ["Pier-Hugues Pellerin"]
  spec.email         = ["phpellerin@gmail.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "cabin"
  spec.add_runtime_dependency "rugged"
  spec.add_runtime_dependency "gems"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "awesome_print"
  spec.add_runtime_dependency "octokit"
end
