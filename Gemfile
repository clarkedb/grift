# frozen_string_literal: true

source 'https://rubygems.org'

# Grift's gem dependencies are defined in grift.gemspec
gemspec

gem 'rake', '>= 12.0'

group :development, :test do
  gem 'minitest', '~> 5.25'
  gem 'minitest-reporters', '~> 1.7'
  gem 'simplecov', '~> 0.22'
  gem 'simplecov-cobertura', '~> 3.1'
end

group :development, :lint do
  gem 'overcommit', '>= 0.64'
  gem 'rubocop', '~> 1.75.4'
  gem 'rubocop-minitest', '~> 0.38.2'
  gem 'rubocop-packaging', '~> 0.6.0'
  gem 'rubocop-performance', '~> 1.23.0'
end
