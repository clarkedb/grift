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
    executions = Grift::MockMethod::MockExecutions.new
    assert_empty executions

    args = %w[what is the answer?]
    kwargs = { test: true }
    result = 42
    executions.store(args: args, kwargs: kwargs, result: result)
    refute_empty executions
    assert_equal 1, executions.count

    assert_equal result, executions.results.first
    assert_equal args, executions.calls.first.args
    assert_equal kwargs, executions.calls.first.kwargs
  end
end
