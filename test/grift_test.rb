# frozen_string_literal: true

require 'test_helper'

class GriftTest < Minitest::Test
  def test_mock_returns_a_mock_method
    target_mock = Grift.mock(Target, :full_name, 'Phil Dunphy')
    assert_instance_of Grift::MockMethod, target_mock
  end

  def test_spy_on_returns_a_mock_method
    target_spy = Grift.spy_on(Target, :full_name)
    assert_instance_of Grift::MockMethod, target_spy
  end

  def test_spy_on_mock_implementation_retuns_a_mock_method
    target_mock = Grift.spy_on(Target, :full_name).mock_implementation do
      'My full name'
    end
    assert_instance_of Grift::MockMethod, target_mock
  end

  def test_mock_method_identifies_presently_mocked_methods
    Grift.mock(Target, :full_name, 'Charles Boyle')
    refute_empty Grift.mock_store
    assert Grift.mock_method?(Target, :full_name)
    refute Grift.mock_method?(String, :to_sym)
  end

  def test_clear_mocks_clears_mocks_by_klass
    target_mocks = [
      Grift.mock(Target, :full_name, 'Michael Kelso'),
      Grift.mock(Target, :convince)
    ]
    string_mock = Grift.mock(String, :upcase, 'banana')

    # call methods to populate mock executions
    Target.new.full_name
    Target.new.convince
    'BANANA'.upcase
    (target_mocks + [string_mock]).each do |mock|
      refute_empty mock.mock
    end

    Grift.clear_mocks(Target)
    target_mocks.each do |mock|
      assert_empty mock.mock
    end
    refute_empty string_mock.mock
  end

  def test_reset_mocks_resets_mocks_by_class
    target_mocks = [
      Grift.mock(Target, :full_name, 'Radar O\'Reily'),
      Grift.mock(Target, :convince)
    ]
    string_mock = Grift.mock(String, :upcase, 'banana')

    # call methods to populate mock executions
    Target.new.full_name
    Target.new.convince
    'BANANA'.upcase
    (target_mocks + [string_mock]).each do |mock|
      refute_empty mock.mock
    end

    Grift.reset_mocks(Target)
    target_mocks.each do |mock|
      assert_empty mock.mock
    end
    assert_nil Target.new.full_name
    assert_nil Target.new.convince

    refute_empty string_mock.mock
    refute_nil 'BANANA'.upcase
  end

  def test_restore_mocks_clears_mock_store_by_klass_method
    assert_empty Grift.mock_store
    target_mock = Grift.mock(Target, :full_name, 'Buster Bluth')
    string_mock = Grift.mock(String, :downcase)
    refute_empty Grift.mock_store
    Grift.restore_mocks(Target)
    refute_empty Grift.mock_store
    refute_includes Grift.mock_store, target_mock
    assert_includes Grift.mock_store, string_mock
  end

  def test_restore_mocks_with_watch_refreshes_mock_store
    assert_empty Grift.mock_store
    Grift.mock(Target, :full_name, 'Jason Mendoza')
    refute_empty Grift.mock_store
    Grift.restore_mocks(Target, watch: true)
    refute_empty Grift.mock_store
  end

  def test_clear_all_mocks_clears_mocks
    mocks = [
      Grift.mock(Target, :full_name, 'Michael Kelso'),
      Grift.mock(Target, :convince),
      Grift.mock(String, :upcase, 'banana')
    ]

    # call methods to populate mock executions
    Target.new.full_name
    Target.new.convince
    'BANANA'.upcase
    mocks.each do |mock|
      refute_empty mock.mock
    end

    Grift.clear_all_mocks
    mocks.each do |mock|
      assert_empty mock.mock
    end
  end

  def test_reset_all_mocks_resets_mocks
    mocks = [
      Grift.mock(Target, :full_name, 'Radar O\'Reily'),
      Grift.mock(Target, :convince),
      Grift.mock(String, :upcase, 'banana')
    ]

    # call methods to populate mock executions
    Target.new.full_name
    Target.new.convince
    'BANANA'.upcase
    mocks.each do |mock|
      refute_empty mock.mock
    end

    Grift.reset_all_mocks
    mocks.each do |mock|
      assert_empty mock.mock
    end
    assert_nil Target.new.full_name
    assert_nil Target.new.convince
    assert_nil 'BANANA'.upcase
  end

  def test_restore_all_mocks_clears_mock_store
    assert_empty Grift.mock_store
    Grift.mock(Target, :full_name, 'Kevin Malone')
    refute_empty Grift.mock_store
    Grift.restore_all_mocks
    assert_empty Grift.mock_store
  end

  def test_restore_all_mocks_with_watch_refreshes_mock_store
    assert_empty Grift.mock_store
    Grift.mock(Target, :full_name, 'Glenn Sturgis')
    refute_empty Grift.mock_store
    Grift.restore_all_mocks(watch: true)
    refute_empty Grift.mock_store
  end
end
