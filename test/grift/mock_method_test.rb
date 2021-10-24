# frozen_string_literal: true

require 'test_helper'

class MockMethodTest < Minitest::Test
  def test_it_mocks_an_instance_method_return_value
    true_target_name = 'Michael Scott'
    mock_target_name = 'Dwight Schrute'

    target = Target.new(first_name: 'Michael', last_name: 'Scott')
    assert target.respond_to?(:full_name)
    assert_equal true_target_name, target.full_name

    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    full_name_mock.mock_return_value(mock_target_name)

    mocked_result = target.full_name
    assert_equal mock_target_name, mocked_result
    assert_equal mock_target_name, full_name_mock.mock.results.first

    full_name_mock.mock_restore

    assert_equal true_target_name, target.full_name
  end

  def test_it_mocks_a_class_method_return_value
    target = Target.new(first_name: 'Jerry')
    mock_target = Target.new(first_name: 'Larry')
    assert Target.respond_to?(:mimic)
    assert_equal target.first_name, Target.mimic(target).first_name

    mimic_mock = Grift::MockMethod.new(Target, :mimic)
    mimic_mock.mock_return_value(mock_target)

    mocked_result = Target.mimic(target)
    refute_equal target.first_name, mocked_result.first_name
    assert_equal mock_target, mimic_mock.mock.results.first

    mimic_mock.mock_restore

    assert_equal target.first_name, Target.mimic(target).first_name
  end

  def test_it_raises_an_error_for_mock_implementation
    target_full_name = 'Buster Bluth'
    target = Target.new(first_name: 'Buster', last_name: 'Bluth')
    assert target.respond_to?(:full_name)
    assert_equal target_full_name, target.full_name

    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    assert_raises NotImplementedError do
      full_name_mock.mock_implementation do
        return nil
      end
    end
  end

  def test_returns_mock_executions_type_with_mock_accessor
    target_mock = Grift::MockMethod.new(Target, :full_name)
    assert_instance_of Grift::MockMethod::MockExecutions, target_mock.mock
  end

  def test_it_keeps_method_mocked_on_mock_clear
    skip 'not implemented'
  end

  def test_it_mocks_return_value_nil_on_mock_reset
    skip 'not implemented'
  end

  def test_it_unmocks_method_on_mock_restore
    skip 'not implemented'
  end

  def test_it_clears_executions_on_mock_clear
    skip 'not implemented'
  end

  def test_it_clears_executions_on_mock_reset
    skip 'not implemented'
  end

  def test_it_clears_executions_on_mock_restore
    skip 'not implemented'
  end
end
