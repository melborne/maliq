# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'maliq/version'

Gem::Specification.new do |gem|
  gem.name          = "maliq"
  gem.version       = Maliq::VERSION
  gem.authors       = ["kyoendo"]
  gem.email         = ["postagie@gmail.com"]
  gem.description   = %q{Maliq is a markdown, liquid converter for EPUB's xhtml.}
  gem.summary       = %q{Maliq is a markdown, liquid converter for EPUB's xhtml. It comes with two command 'maliq' and 'maliq\_gepub'. 'maliq' is a markdown-xhtml converter and 'maliq\_gepub' is a wrapper of gepub gem which is a EPUB generator.}
  gem.homepage      = "https://github.com/melborne/maliq"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.required_ruby_version = '>=1.9.3'
  gem.add_dependency 'trollop'
  gem.add_dependency 'rdiscount'
  gem.add_dependency 'liquid'
  gem.add_dependency 'gepub'
  gem.add_development_dependency 'rspec'
end
