# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bomdb/version'

Gem::Specification.new do |spec|
  spec.name          = "bomdb"
  spec.version       = BomDB::VERSION
  spec.authors       = ["Duane Johnson"]
  spec.email         = ["duane.johnson@gmail.com"]
  spec.summary       = %q{Book of Mormon Database}
  spec.description   = %q{A command-line queryable database of multiple editions of the Book of Mormon}
  spec.homepage      = "http://bomdb.wordtree.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject{ |f| f =~ %r|data/.*\.json| }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.bindir        = "bin"

  spec.add_dependency 'sequel',          '~> 4.49'
  spec.add_dependency 'sqlite3',         '~> 1.4'
  spec.add_dependency 'thor',            '~> 0.20'
  spec.add_dependency 'constellation',   '~> 0.1'
  spec.add_dependency 'colorize',        '~> 0.7'
  spec.add_dependency 'text_clean',      '~> 0'
  spec.add_dependency 'levenshtein-ffi', '~> 1.1'
  spec.add_dependency 'mericope',        '~> 0.3'

  # spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake',    '~> 13.0'
  spec.add_development_dependency 'byebug',  '~> 4.0'
  spec.add_development_dependency 'rspec',   '~> 3.2'
end
