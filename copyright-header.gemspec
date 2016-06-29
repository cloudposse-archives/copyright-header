# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "copyright_header/version"

Gem::Specification.new do |s|
  s.name        = "copyright-header"
  s.version     = CopyrightHeader::VERSION
  s.authors     = ["Erik Osterman"]
  s.email       = ["e@osterman.com"]
  s.licenses    = ["GPL-3"]
  s.homepage    = "https://github.com/osterman/copyright-header"
  s.summary     = %q{A utility to insert copyright headers into various types of source code files}
  s.description = %q{A utility which is able to recursively insert and remove copyright headers from source code files based on file extensions.}
  s.rubyforge_project = "copyright-header"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ['README.md', 'LICENSE', 'AUTHORS', 'contrib/syntax.yml' ]
  s.require_paths = ["lib"]
  s.add_dependency('github-linguist')
end
