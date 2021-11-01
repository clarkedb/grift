# frozen_string_literal: true

require 'test_helper'

class MockStoreTest < Minitest::Test
  def test_it_initializes_to_empty
    mock_store = Grift::MockStore.new
    assert_empty mock_store
  end

  def test_it_can_store_a_mock_method
    mock_store = Grift::MockStore.new
    refute_includes mock_store, Grift::MockMethod.hash_key(Target, :mimic)
    mock = Grift::MockMethod.new(Target, :mimic)
    mock_store.store(mock)
    assert_includes mock_store, Grift::MockMethod.hash_key(Target, :mimic)
    assert_includes mock_store, mock
  end

  def test_it_raises_an_error_when_asked_to_store_non_mocks
    mock_store = Grift::MockStore.new
    non_mock_object = 'hello'
    refute_instance_of Grift::MockMethod, non_mock_object
    assert_raises Grift::Error do
      mock_store.store(non_mock_object)
    end
  end

  def test_it_raises_an_error_when_duplicate_mock_stored
    mock_store = Grift::MockStore.new
    mock = Grift::MockMethod.new(Target, :mimic, watch: false)
    mock_store.store(mock)
    assert_includes mock_store, mock
    new_mock = Grift::MockMethod.new(Target, :mimic, watch: false)
    assert_raises Grift::Error do
      mock_store.store(new_mock)
    end
  end

  def test_it_returns_the_correct_mocks
    mock_store = Grift::MockStore.new
    mimic_mock = Grift::MockMethod.new(Target, :mimic)
    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    upcase_mock = Grift::MockMethod.new(String, :upcase)
    target_mocks = [mimic_mock, full_name_mock]
    mocks = target_mocks + [upcase_mock]
    mocks.each { |mock| mock_store.store(mock) }

    assert_equal upcase_mock, mock_store.mocks(method: :upcase).first
    target_mocks.each do |mock|
      assert_includes mock_store.mocks(klass: Target), mock
    end

    mocks.each do |mock|
      assert_includes mock_store.mocks, mock
    end
  end

  def test_it_can_remove_a_mock_from_the_store_by_search_criteria
    mock_store = Grift::MockStore.new
    mimic_mock = Grift::MockMethod.new(Target, :mimic)
    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    [mimic_mock, full_name_mock].each do |mock|
      mock_store.store(mock)
      assert_includes mock_store, mock
    end
    mock_store.remove(klass: Target, method: :full_name)
    refute_includes mock_store, full_name_mock
    assert_includes mock_store, mimic_mock
  end

  def test_it_can_detele_a_mock_from_the_store_by_instance
    mock_store = Grift::MockStore.new
    mimic_mock = Grift::MockMethod.new(Target, :mimic)
    full_name_mock = Grift::MockMethod.new(Target, :full_name)
    [mimic_mock, full_name_mock].each do |mock|
      mock_store.store(mock)
      assert_includes mock_store, mock
    end
    mock_store.delete(mimic_mock)
    refute_includes mock_store, mimic_mock
    assert_includes mock_store, full_name_mock
  end

  def test_it_skips_deleting_unstore_mocks
    mock_store = Grift::MockStore.new
    mimic_mock = Grift::MockMethod.new(Target, :mimic)
    refute_includes mock_store, mimic_mock
    mock_store.delete(mimic_mock)
    refute_includes mock_store, mimic_mock
  end
end
