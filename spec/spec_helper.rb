# frozen_string_literal: true

require 'bundler/setup'
require 'timecop'
require 'pry'

require 'simplecov'
require 'undercover/simplecov_formatter'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::Undercover, SimpleCov::Formatter::HTMLFormatter]
)
SimpleCov.start do
  add_filter(/^\/spec\//)
  enable_coverage(:branch)
end
# The gemspec loads the version before SimpleCov starts, so load it again to measure it
load File.expand_path('../lib/version.rb', __dir__)

require 'pronto/undercover'
require 'pronto/patch_changeset'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
