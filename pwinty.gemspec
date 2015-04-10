# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pwinty/version"

Gem::Specification.new do |s|
  s.name        = "pwinty"
  s.version     = Pwinty::VERSION
  s.authors     = ["Derek Lucas"]
  s.email       = ["d@derekplucas.com"]
  s.homepage    = ""
  s.summary     = %q{A Ruby client for the Pwinty API}
  s.description = %q{Order photo prints with Ruby}

  s.rubyforge_project = "pwinty"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "dotenv"
  s.add_runtime_dependency "rest-client", '~> 1.8'
end
