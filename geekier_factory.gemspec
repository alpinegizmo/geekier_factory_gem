# -*- encoding: utf-8 -*-
require File.expand_path("../lib/geekier_factory/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "geekier_factory"
  s.version     = GeekierFactory::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christian Weis", "David Anderson"]
  s.email       = "team@rules.io"
  s.homepage    = "http://github.com/rulesio/geekier_factory_gem"
  s.summary     = "Generate API objects from swagger definition files"
  s.description = "Generate API objects from swagger definition files"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", "~> 1"
  s.add_development_dependency "test-unit", "~> 2.2"
  s.add_development_dependency "mocha"
  s.add_development_dependency "rake"
  s.add_development_dependency "webmock"
  
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"
  s.add_dependency "faraday_body_logger"

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'
end
