[![Build Status](https://travis-ci.org/grodowski/pronto-undercover.svg?branch=master)](https://travis-ci.org/grodowski/pronto-undercover)

# Pronto::Undercover

Pronto runner for [Undercover](https://github.com/grodowski/undercover), an actionable code coverage tool. What is [Pronto](https://github.com/prontolabs/pronto)?

## Installation

Add this line to your application's Gemfile

```ruby
gem 'pronto-undercover'
```

or install the gem with

```shell
gem install pronto-undercover
```

Once installed, `pronto run` will include undercover warnings. You can verify the install by running `pronto list`.

## Configuring

`pronto-undercover` stores options passed to undercover in `.pronto.yml`. Please note that `--git-dir` and `--compare` options are not available, because `pronto-undercover` uses `Pronto::Git` instead of undercover's implementation.

`min-coverage`: Minimum coverage for `coverage:`, not raise warning if more than it.

Available options:

```
# .pronto.yml
# ...other configuration
pronto-undercover:
  path: path/to/project
  lcov: path/to/project/coverage/report.lcov
  ruby-syntax: ruby19
  min-coverage: 1
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
