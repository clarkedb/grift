# frozen_string_literal: true

require 'test_helper'

class MockMethodTest < Minitest::Test
  def test_it_mocks_an_instance_method_return_value
    true_target_name = 'Michael Scott'
    mock_target_name = 'Dwight Schrute'

    target = Target.new(first_name: 'Michael', last_name: 'Scott')
    assert_respond_to target, :full_name
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
    assert_respond_to Target, :mimic
    assert_equal target.first_name, Target.mimic(target).first_name

    mimic_mock = Grift::MockMethod.new(Target, :mimic)
    mimic_mock.mock_return_value(mock_target)

    mocked_result = Target.mimic(target)
    refute_equal target.first_name, mocked_result.first_name
    assert_equal mock_target, mimic_mock.mock.results.first

    mimic_mock.mock_restore

    assert_equal target.first_name, Target.mimic(target).first_name
  end

  def test_it_watches_the_method_by_default
    target_full_name = 'Tobias Funke'
    target = Target.new(first_name: 'Tobias', last_name: 'Funke')
    assert_equal target_full_name, target.full_name

    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    assert_equal target_full_name, target.full_name

    refute_empty full_name_mock.mock
    assert_empty full_name_mock.mock.calls.first
    assert_equal target_full_name, full_name_mock.mock.results.first
  end

  def test_it_does_not_watch_if_watch_is_false
    target_full_name = 'Tobias Funke'
    target = Target.new(first_name: 'Tobias', last_name: 'Funke')
    assert_equal target_full_name, target.full_name

    full_name_mock = Grift::MockMethod.new(Target, :full_name, watch: false)
    assert_equal target_full_name, target.full_name

    assert_empty full_name_mock.mock
  end

  def test_mock_restore_unwatches_by_default
    target_full_name = 'Tobias Funke'
    target = Target.new(first_name: 'Tobias', last_name: 'Funke')
    assert_equal target_full_name, target.full_name

    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    assert_equal target_full_name, target.full_name
    refute_empty full_name_mock.mock

    full_name_mock.mock_restore

    assert_equal target_full_name, target.full_name
    assert_empty full_name_mock.mock
  end

  def test_mock_restore_rewatches_when_watch_true
    target_full_name = 'Tobias Funke'
    target = Target.new(first_name: 'Tobias', last_name: 'Funke')
    assert_equal target_full_name, target.full_name

    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    assert_equal target_full_name, target.full_name
    refute_empty full_name_mock.mock

    full_name_mock.mock_restore(watch: true)

    assert_equal target_full_name, target.full_name
    refute_empty full_name_mock.mock
  end

  def test_it_mocks_an_instance_method_implementation
    target_full_name = 'Buster Bluth'
    target = Target.new(first_name: 'Buster', last_name: 'Bluth')
    assert_respond_to target, :full_name
    assert_equal target_full_name, target.full_name

    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    full_name_mock.mock_implementation do
      [target.last_name, target.first_name].join(' ')
    end

    expected_full_name_result = target_full_name.split.reverse.join(' ')
    assert_equal expected_full_name_result, target.full_name

    assert_empty full_name_mock.mock.calls.first
    assert_equal expected_full_name_result, full_name_mock.mock.results.first
  end

  def test_it_mocks_an_class_method_implementation
    target = Target.new(first_name: 'Jerry')
    assert_respond_to Target, :mimic
    assert_equal target.first_name, Target.mimic(target).first_name

    mimic_mock = Grift::MockMethod.new(Target, :mimic)
    mimic_mock.mock_implementation do |t|
      t.full_name * 2
    end

    mocked_result = Target.mimic(target)
    expected_mimic_result = target.full_name * 2
    assert_equal expected_mimic_result, mocked_result

    assert_equal [target], mimic_mock.mock.calls.first
    assert_equal expected_mimic_result, mimic_mock.mock.results.first
  end

  def test_returns_mock_executions_type_with_mock_accessor
    target_mock = Grift::MockMethod.new(Target, :full_name, watch: false)
    assert_instance_of Grift::MockMethod::MockExecutions, target_mock.mock
  end

  def test_it_clears_executions_and_keeps_method_mocked_on_mock_clear
    target = Target.new(gullible: true)
    assert_respond_to target, :convince
    assert_instance_of Array, target.convince('The earth is flat')

    convince_mock = Grift::MockMethod.new(Target, :convince)
    convince_mock.mock_return_value('mocked')
    assert_equal 'mocked', target.convince('The earth is round')
    refute_empty convince_mock.mock

    convince_mock.mock_clear
    assert_empty convince_mock.mock
    assert_equal 'mocked', target.convince('The earth is round')
  end

  def test_it_clears_executions_and_mocks_return_value_nil_on_mock_reset
    target = Target.new(gullible: true)
    assert_respond_to target, :convince
    assert_instance_of Array, target.convince('The earth is flat')

    convince_mock = Grift::MockMethod.new(Target, :convince)
    convince_mock.mock_return_value('mocked')
    assert_equal 'mocked', target.convince('The earth is round')
    refute_empty convince_mock.mock

    convince_mock.mock_reset
    assert_empty convince_mock.mock
    assert_nil target.convince('The earth is round')
  end

  def test_it_clears_executions_and_unmocks_method_on_mock_restore
    target = Target.new(gullible: true)
    assert_respond_to target, :convince
    assert_instance_of Array, target.convince('The earth is flat')

    convince_mock = Grift::MockMethod.new(Target, :convince)
    convince_mock.mock_return_value('mocked')
    assert_equal 'mocked', target.convince('The earth is round')
    refute_empty convince_mock.mock

    convince_mock.mock_restore
    assert_empty convince_mock.mock
    refute_equal 'mocked', target.convince('The earth is round')
    assert_instance_of Array, target.convince('The earth is round')
  end

  def test_raises_error_when_unmock_called_and_not_mocked
    target_mock = Grift::MockMethod.new(Target, :convince, watch: false)
    assert_raises Grift::Error do
      target_mock.send(:unmock_method)
    end
  end

  def test_raises_error_when_cache_called_and_already_cached
    target_mock = Grift::MockMethod.new(Target, :convince)
    target_mock.mock_return_value
    assert_raises Grift::Error do
      target_mock.send(:cache_method)
    end
  end

  def test_raises_error_when_unknwon_method_mocked
    refute_respond_to String, :banana
    assert_raises Grift::Error do
      Grift::MockMethod.new(String, :banana)
    end
  end

  def test_it_has_hash_key_string_representation
    target_mock = Grift::MockMethod.new(Target, :convince)
    expected_string = Grift::MockMethod.hash_key(target_mock.klass, target_mock.method_name)
    assert_equal expected_string, target_mock.to_s
  end

  def test_it_produces_hash_key_by_klass_and_method
    klass = String
    method = :downcase
    hash_key = Grift::MockMethod.hash_key(klass, method)
    assert_includes hash_key, klass.to_s
    assert_includes hash_key, method.to_s

    # hash_key should be same for equivalent mocks
    assert_equal hash_key, Grift::MockMethod.hash_key(klass, method)
  end

  def test_raises_error_when_initializing_for_restricted_method
    assert_raises Grift::Error do
      Grift::MockMethod.new(Grift::MockMethod, :mock_implementation)
    end
  end

  def test_raises_error_when_method_already_mocked
    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    assert_includes Grift.mock_store, full_name_mock
    assert_raises Grift::Error do
      Grift::MockMethod.new(Target, :full_name)
    end
  end

  def test_it_mocks_a_constructor
    Grift::MockMethod.new(Target, :new).mock_return_value
    assert_nil Target.new(first_name: 'Jim')
  end
end
