# frozen_string_literal: true

require 'test_helper'

class MinitestPluginTest < Minitest::Test
  def test_it_defines_a_before_teardown_hook
    assert_includes Grift::MinitestPlugin.instance_methods, :before_teardown
  end
end
