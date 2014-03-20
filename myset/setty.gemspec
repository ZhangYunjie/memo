# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'setty/version'

Gem::Specification.new do |gem|
  gem.name          = "setty"
  gem.version       = Setty::VERSION
  gem.authors       = ["Takeo Fujita"]
  gem.email         = ["takeo@drecom.co.jp"]
  gem.description   = %q{loading application configuration from yaml file}
  gem.summary       = %q{application configuration}
  gem.homepage      = "http://git.drecom.jp/sgt/setty"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport", [">= 3.0.0", "< 5.0"]
  gem.add_dependency "hashie", ">= 1.2.0"
end
