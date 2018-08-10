# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = 'pronto-undercover'
  spec.version       = Pronto::UndercoverVersion::VERSION
  spec.authors       = ['Jan Grodowski']
  spec.email         = ['jgrodowski@gmail.com']

  spec.summary       = 'Pronto runner for Undercover - actionable code coverage'
  spec.homepage      = 'https://github.com/grodowski/pronto-undercover'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'pronto', '~> 0.9.0'
  spec.add_dependency 'undercover', '~> 0.1.8'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'timecop'
end
