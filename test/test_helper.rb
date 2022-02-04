# frozen_string_literal: true

# configure code coverage
unless ENV['CODE_COVERAGE'] == 'false'
  require 'simplecov'
  SimpleCov.start do
    add_filter %w[bin docs db log pkg test tmp]

    add_group 'Grift', 'lib/grift.rb'
    add_group 'Grift Internals', 'lib/grift/'

    enable_coverage :branch
  end
end

# load gem files
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'grift'

# configure minitest
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

# classes for mock tests
require 'target'

# rubocop:disable Style/ClassAndModuleChildren
class Minitest::Test
  include Grift::MinitestPlugin
end
# rubocop:enable Style/ClassAndModuleChildren
