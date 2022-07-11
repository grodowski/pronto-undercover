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
    f.match(/^(test|spec|features)\//)
  end
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'pronto', '>= 0.9', '< 0.12'
  spec.add_dependency 'undercover', '~> 0.4.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-html'
  spec.add_development_dependency 'simplecov-lcov'
  spec.add_development_dependency 'timecop'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
