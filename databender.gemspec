# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'databender/version'

Gem::Specification.new do |s|
  s.name          = 'databender'
  s.version       = Databender::VERSION
  s.authors       = ['RC']
  s.email         = ['rc.chandru@gmail.com']
  s.summary       = %q{Database subset generator}
  s.description   = %q{Database subset generator}
  s.homepage      = ''
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/rcdexta/databender'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = ['databender']
  s.test_files    = s.files.grep(%r{^(test|s|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'thor', '~> 0.20.0'
  s.add_dependency 'activerecord', '=5.1.4'
  s.add_dependency 'mysql2', '=0.4.9'
  s.add_dependency 'mustache', '~> 1.0', '>= 1.0.5'
  s.add_dependency 'configatron', '~> 4.5', '>= 4.5.1'
  s.add_dependency 'terminal-table', '~> 1.8', '>= 1.8.0'

  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'pry', '~> 0'

end
