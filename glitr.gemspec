# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "glitr/version"

Gem::Specification.new do |s|
  s.name        = "glitr"
  s.version     = Glitr::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jared Pace"]
  s.email       = ["jared@codewordstudios.com"]
  s.homepage    = "https://github.com/jdpace/glitr"
  s.summary     = %q{ActiveRecord like interface for SPARQL}
  s.description = %q{Builds and performs SPARQL queries against Joseki server using an ActiveRecord like interface}

  s.rubyforge_project = "glitr"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Runtime Dependencies
  s.add_runtime_dependency 'typhoeus', ['~> 0.2.4']
  s.add_runtime_dependency 'bamfcsv', ['~> 0.3.0']

  # Developmnet Dependencies
  s.add_development_dependency 'rspec', ['~> 2.6.0']
  s.add_development_dependency 'mocha', ['~> 0.9.10']
end
