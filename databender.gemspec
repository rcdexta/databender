# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'databender/version'

Gem::Specification.new do |spec|
  spec.name          = 'databender'
  spec.version       = Databender::VERSION
  spec.authors       = ['RC']
  spec.email         = ['rc.chandru@gmail.com']
  spec.summary       = %q{Database subset generator}
  spec.description   = %q{Database subset generator}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ['databender']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'thor'
  spec.add_dependency 'activerecord'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'mysql2'
  spec.add_dependency 'mustache'
  spec.add_dependency 'configatron'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'

end
