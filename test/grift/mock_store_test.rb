# frozen_string_literal: true

require 'test_helper'

class MockStoreTest < Minitest::Test
  def test_it_initializes_to_empty
    mock_store = Grift::MockStore.new
    assert_empty mock_store
  end
end
