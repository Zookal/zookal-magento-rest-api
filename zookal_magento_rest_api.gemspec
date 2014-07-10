# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zookal_magento_rest_api/version'

Gem::Specification.new do |spec|
  spec.name          = "zookal_magento_rest_api"
  spec.version       = ZookalMagentoRestApi::VERSION
  spec.authors       = ["Michael Imstepf"]
  spec.email         = ["michael.imstepf@gmail.com"]
  spec.summary       = %q{Ruby wrapper for the Zookal Magento REST API}
  spec.description   = %q{Gem to do backend REST API calls to Zookal's Magento store. Prior authentication (through oAuth) required.}
  spec.homepage      = "https://github.com/Zookal/zookal-magento-rest-api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "oauth"
  spec.add_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"  
  spec.add_development_dependency "pry"    
end
