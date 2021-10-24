# frozen_string_literal: true

require 'test_helper'

class MockExecutionsTest < Minitest::Test
  def test_it_initializes_as_empty
    executions = Grift::MockMethod::MockExecutions.new
    assert_empty executions
    assert_empty executions.calls
    assert_empty executions.results
  end

  def test_it_stores_results_and_args
    skip 'not implemented'
  end

  def test_it_returns_only_args_on_calls
    skip 'not implemented'
  end

  def test_it_returns_only_results_on_results
    skip 'not implemented'
  end
end
