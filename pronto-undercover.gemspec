lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pronto/undercover/version"

Gem::Specification.new do |spec|
  spec.name          = "pronto-undercover"
  spec.version       = Pronto::Undercover::VERSION
  spec.authors       = ["Jan Grodowski"]
  spec.email         = ["jgrodowski@gmail.com"]

  spec.summary       = %q{Pronto runner for Undercover - actionable code coverage}
  spec.homepage      = "https://github.com/grodowski/pronto-undercover"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency('undercover', '~> 0.1.0')
  spec.add_runtime_dependency('pronto', '~> 0.9.0')
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
