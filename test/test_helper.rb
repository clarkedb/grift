# frozen_string_literal: true

# code coverage configuration
unless ENV['CODE_COVERAGE'] == 'false'
  require 'simplecov'
  SimpleCov.start do
    add_filter %w[bin docs db log pkg test tmp]

    add_group 'Grift', 'lib/grift.rb'
    add_group 'Grift Internals', 'lib/grift/'

    enable_coverage :branch
  end
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'grift'

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!
