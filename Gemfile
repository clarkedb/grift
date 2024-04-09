# frozen_string_literal: true

source 'https://rubygems.org'

# Grift's gem dependencies are defined in grift.gemspec
gemspec

gem 'rake', '>= 12.0'

group :development, :test do
  gem 'minitest', '>= 5.0'
  gem 'minitest-reporters', '>= 1.4.3'
  gem 'simplecov', '>= 0.21.2'
  gem 'simplecov-cobertura', '>= 2.1.0'
end

group :development, :lint do
  gem 'overcommit'
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-packaging', '>= 0.5'
  gem 'rubocop-performance', '>= 1.0'
end
