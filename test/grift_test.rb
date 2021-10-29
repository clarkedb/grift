# frozen_string_literal: true

require 'test_helper'

class GriftTest < Minitest::Test
  def test_mock_returns_a_mock_method
    target_mock = Grift.mock(Target, :full_name, 'Glenn Sturgis')
    assert_instance_of Grift::MockMethod, target_mock
    target_mock.mock_restore
  end

  def test_spy_on_returns_a_mock_method
    target_spy = Grift.spy_on(Target, :full_name)
    assert_instance_of Grift::MockMethod, target_spy
    target_spy.mock_restore
  end

  def test_spy_on_mock_implementation_retuns_a_mock_method
    target_mock = Grift.spy_on(Target, :full_name).mock_implementation do
      'My full name'
    end
    assert_instance_of Grift::MockMethod, target_mock
    target_mock.mock_restore
  end

  def test_mock_method_raises_error
    assert_raises NotImplementedError do
      Grift.mock_method?(Target, :convince)
    end
  end

  def test_clear_mocks_raises_error
    assert_raises NotImplementedError do
      Grift.clear_mocks(Target)
    end
  end

  def test_reset_mocks_raises_error
    assert_raises NotImplementedError do
      Grift.reset_mocks(Target)
    end
  end

  def test_restore_mocks_raises_error
    assert_raises NotImplementedError do
      Grift.restore_mocks(Target)
    end
  end

  def test_clear_all_mocks_raises_error
    assert_raises NotImplementedError do
      Grift.clear_all_mocks
    end
  end

  def test_reset_all_mocks_raises_error
    assert_raises NotImplementedError do
      Grift.reset_all_mocks
    end
  end

  def test_restore_all_mocks_raises_error
    assert_raises NotImplementedError do
      Grift.restore_all_mocks
    end
  end
end
