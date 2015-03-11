# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sandthorn_sequel_projection/version'

Gem::Specification.new do |spec|
  spec.name          = "sandthorn_sequel_projection"
  spec.version       = SandthornSequelProjection::VERSION
  spec.authors       = ["Lars Krantz"]
  spec.email         = ["lars.krantz@alaz.se"]
  spec.summary       = %q{Helps creating sql projections from sandthorn events}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sandthorn_driver_sequel", "~> 2.0.0"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "codeclimate-test-reporter"

  spec.add_runtime_dependency     "sandthorn", "~> 0.7"
  spec.add_runtime_dependency     "sandthorn_event_filter", "~> 0.0.4"
  spec.add_runtime_dependency     "sequel"
  spec.add_runtime_dependency     "simple_migrator", "~> 0.0.2"

end
