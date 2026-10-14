# frozen_string_literal: true

require 'test_helper'

class MinitestPluginTest < Minitest::Test
  def test_it_defines_an_after_teardown_hook
    assert_includes Grift::MinitestPlugin.instance_methods, :after_teardown
  end

  def test_assert_mocked_passes_when_mocked
    Grift.spy_on(Target, :full_name)

    assert_mocked Target, :full_name
  end

  def test_assert_mocked_fails_when_not_mocked
    error = assert_raises(Minitest::Assertion) { assert_mocked(Target, :full_name) }

    assert_equal 'Expected Target#full_name to be mocked.', error.message
  end

  def test_assert_mocked_prepends_a_custom_message
    error = assert_raises(Minitest::Assertion) { assert_mocked(Target, :full_name, 'Spy first') }

    assert_equal "Spy first.\nExpected Target#full_name to be mocked.", error.message
  end

  def test_refute_mocked_passes_when_not_mocked
    refute_mocked Target, :full_name
  end

  def test_refute_mocked_fails_when_mocked
    Grift.spy_on(Target, :full_name)

    error = assert_raises(Minitest::Assertion) { refute_mocked(Target, :full_name) }

    assert_equal 'Expected Target#full_name to not be mocked.', error.message
  end

  def test_assert_mock_called_passes_when_called
    mock = Grift.spy_on(Target, :full_name)
    Target.new.full_name

    assert_mock_called mock
  end

  def test_assert_mock_called_fails_when_not_called
    mock = Grift.spy_on(Target, :full_name)

    error = assert_raises(Minitest::Assertion) { assert_mock_called(mock) }

    assert_equal 'Expected Target#full_name to be called.', error.message
  end

  def test_refute_mock_called_passes_when_not_called
    mock = Grift.spy_on(Target, :full_name)

    refute_mock_called mock
  end

  def test_refute_mock_called_fails_and_lists_the_calls
    mock = Grift.spy_on(Target, :convince)
    target = Target.new
    target.convince('the sky is green')
    target.convince('cats are dogs')

    error = assert_raises(Minitest::Assertion) { refute_mock_called(mock) }

    expected = <<~MSG.chomp
      Expected Target#convince to not be called, but it was called with:
        ("the sky is green")
        ("cats are dogs")
    MSG
    assert_equal expected, error.message
  end

  def test_assert_mock_called_with_passes_when_any_call_matches
    mock = Grift.spy_on(Target, :convince)
    target = Target.new
    target.convince('the sky is green')
    target.convince('cats are dogs')

    assert_mock_called_with mock, 'cats are dogs'
  end

  def test_assert_mock_called_with_matches_keyword_arguments
    mock = Grift.spy_on(Target, :change_name)
    Target.new.change_name(first_name: 'Lindsay', last_name: 'Bluth')

    assert_mock_called_with mock, first_name: 'Lindsay', last_name: 'Bluth'
  end

  def test_assert_mock_called_with_matches_keyword_arguments_of_a_mocked_implementation
    mock = Grift.spy_on(Target, :change_name).mock_implementation { |**| nil }
    Target.new.change_name(first_name: 'Lindsay', last_name: 'Bluth')

    assert_mock_called_with mock, first_name: 'Lindsay', last_name: 'Bluth'
  end

  def test_mock_called_with_compares_using_the_expected_arguments
    mock = Grift.spy_on(Target, :mimic)
    Target.mimic(Target.new)

    # Target#== would raise if given a string
    refute_mock_called_with mock, 'Tobias Funke'
  end

  def test_assert_mock_called_with_fails_when_not_called
    mock = Grift.spy_on(Target, :convince)

    error = assert_raises(Minitest::Assertion) { assert_mock_called_with(mock, 'a', b: 1) }

    assert_equal 'Expected Target#convince to be called with ("a", b: 1), but it was not called.', error.message
  end

  def test_assert_mock_called_with_fails_and_lists_the_calls
    mock = Grift.spy_on(Target, :change_name)
    Target.new.change_name(first_name: 'Lindsay')

    error = assert_raises(Minitest::Assertion) { assert_mock_called_with(mock, first_name: 'Maeby') }

    expected = <<~MSG.chomp
      Expected Target#change_name to be called with (first_name: "Maeby"), but it was called with:
        (first_name: "Lindsay")
    MSG
    assert_equal expected, error.message
  end

  def test_refute_mock_called_with_passes_when_no_call_matches
    mock = Grift.spy_on(Target, :convince)
    Target.new.convince('the sky is green')

    refute_mock_called_with mock, 'cats are dogs'
  end

  def test_refute_mock_called_with_fails_when_a_call_matches
    mock = Grift.spy_on(Target, :convince)
    Target.new.convince('the sky is green')

    error = assert_raises(Minitest::Assertion) { refute_mock_called_with(mock, 'the sky is green') }

    assert_equal 'Expected Target#convince to not be called with ("the sky is green").', error.message
  end
end
