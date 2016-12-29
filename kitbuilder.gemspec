# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kitbuilder/version"

Gem::Specification.new do |s|
  s.name        = "kitbuilder"
  s.version     = Kitbuilder::VERSION
  s.authors     = ["Klaus Kämpf"]
  s.email       = ["kkaempf@suse.de"]
  s.homepage    = "http://github.com/kkaempf/kitbuilder"
  s.summary     = %q{Simply build tetra -kit}
  s.description = %q{Build tetra -kit simply}

  s.rubyforge_project = "kitbuilder"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
