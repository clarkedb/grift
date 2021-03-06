# frozen_string_literal: true

require 'test_helper'

class ConfigTest < Minitest::Test
  def test_it_has_a_restricted_methods_config_reader
    assert_respond_to Grift::Config, :restricted_methods
  end
end
