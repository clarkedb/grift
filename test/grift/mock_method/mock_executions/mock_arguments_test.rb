# frozen_string_literal: true

require 'test_helper'

class MockArgumentsTest < Minitest::Test
  def test_it_includes_enumerable
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new
    assert_kind_of Enumerable, mock_arguments
  end

  def test_it_implements_each
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new
    assert_respond_to mock_arguments, :each
  end

  def test_it_can_access_keyword_argument_by_symbol
    kwargs = { argument_one: 'one', argument_two: 'two' }
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new(kwargs: kwargs)
    assert_nil mock_arguments[0]
    kwargs.each_key do |key|
      assert_equal kwargs[key], mock_arguments[key]
      assert_equal kwargs[key], mock_arguments[key.to_s]
    end
  end

  def test_it_can_access_positional_argument_by_index
    args = %w[it works great]
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new(args: args)
    assert_nil mock_arguments['0']
    args.length.times.each do |i|
      assert_equal args[i], mock_arguments[i]
    end
  end

  def test_raises_error_when_attempting_bracket_access_with_unknown_type
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new
    assert_raises Grift::Error do
      mock_arguments[{ a_hash: 'is not valid' }]
    end
  end

  def test_it_returns_correct_values_for_first_and_last_with_keyword_args
    kwargs = { test_1: 'first', test_2: 'middle', test_3: 'last' }
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new(kwargs: kwargs)
    assert_equal kwargs[:test_1], mock_arguments.first
    assert_equal kwargs[:test_3], mock_arguments.last
  end

  def test_it_returns_correct_values_for_first_and_last_with_positional_args
    args = %w[first is not last]
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new(args: args)
    assert_equal args.first, mock_arguments.first
    assert_equal args.last, mock_arguments.last
  end

  def test_it_returns_correct_values_for_first_and_last_with_blended_args
    args = %w[first is not last]
    kwargs = { test_1: 'first', test_2: 'middle', test_3: 'last' }
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new(args: args, kwargs: kwargs)
    assert_equal args.first, mock_arguments.first
    assert_equal kwargs[:test_3], mock_arguments.last
  end

  def test_it_computes_correct_length
    args = (0..5).to_a
    kwargs = { test_1: 'test', test_2: 'test' }
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new(args: args, kwargs: kwargs)
    assert_equal args.length + kwargs.length, mock_arguments.length
  end

  def test_it_determines_empty_accurately
    assert_empty Grift::MockMethod::MockExecutions::MockArguments.new
    refute_empty Grift::MockMethod::MockExecutions::MockArguments.new(args: ['test'])
  end

  def test_it_returns_positional_argument_keys
    args = (0..5).to_a
    kwargs = { test_1: 'test', test_2: 'test' }
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new(args: args, kwargs: kwargs)
    assert_equal %i[test_1 test_2], mock_arguments.keys
  end

  def test_it_returns_all_values
    args = (0..5).to_a
    kwargs = { test_1: 'test', test_2: 'test' }
    mock_arguments = Grift::MockMethod::MockExecutions::MockArguments.new(args: args, kwargs: kwargs)
    expected_values = args + kwargs.values
    assert_equal expected_values, mock_arguments.values
  end
end
