# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruboty/pdq/version'

Gem::Specification.new do |spec|
  spec.name          = "ruboty-pdq"
  spec.version       = Ruboty::Pdq::VERSION
  spec.authors       = ["m_oomote"]
  spec.email         = ["m_oomote@dreamarts.co.jp"]
  spec.summary       = %q{ruboty plugin for popybot. pd-question notification tool}
  spec.description   = %q{ruboty plugin for popybot. pd-question notification tool}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ruboty"
  spec.add_runtime_dependency "addressable"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "ruboty-redis"
end
