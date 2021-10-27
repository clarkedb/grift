# frozen_string_literal: true

require 'test_helper'

class MockCacheTest < Minitest::Test
  def test_it_raises_an_error_on_initialize
    assert_raises NotImplementedError do
      Grift::MockCache.new
    end
  end
end
