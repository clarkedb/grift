# frozen_string_literal: true

require 'test_helper'

class MinitestPluginTest < Minitest::Test
  def test_it_defines_an_after_teardown_hook
    assert_includes Grift::MinitestPlugin.instance_methods, :after_teardown
  end
end
