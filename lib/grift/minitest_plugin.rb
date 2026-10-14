# frozen_string_literal: true

module Grift
  ##
  # A plugin to clean up mocks after tests in Minitest and to assert on mocks.
  # It is recommended that you include this plugin to avoid
  # needing to cleanup the mocks after each test.
  #
  # To setup the plugin for your tests, you should include the
  # following code in your +test_helper+
  #
  #   class Minitest::Test
  #     include Grift::MinitestPlugin
  #   end
  #
  module MinitestPlugin
    ##
    # After each test restores all mocks with no watching.
    #
    # @return [Grift::MockStore]
    #
    def after_teardown
      super
      Grift.restore_all_mocks(watch: false)
    end

    ##
    # Asserts that the given method is currently mocked.
    #
    # @see Grift.mock_method?
    #
    # @example
    #   Grift.spy_on(MyClass, :my_method)
    #   assert_mocked(MyClass, :my_method)
    #
    # @param klass [Class] the class of the method to be checked
    # @param method [Symbol] the symbol representing the method to be checked
    # @param msg [String, Proc] a message to show before the failure message
    #
    # @return [true]
    #
    def assert_mocked(klass, method, msg = nil)
      key = Grift::MockMethod.hash_key(klass, method)
      assert Grift.mock_method?(klass, method), message(msg) { "Expected #{key} to be mocked" }
    end

    ##
    # Asserts that the given method is not currently mocked.
    #
    # @see Grift.mock_method?
    #
    # @example
    #   refute_mocked(MyClass, :my_method)
    #
    # @param klass [Class] the class of the method to be checked
    # @param method [Symbol] the symbol representing the method to be checked
    # @param msg [String, Proc] a message to show before the failure message
    #
    # @return [true]
    #
    def refute_mocked(klass, method, msg = nil)
      key = Grift::MockMethod.hash_key(klass, method)
      refute Grift.mock_method?(klass, method), message(msg) { "Expected #{key} to not be mocked" }
    end

    ##
    # Asserts that the mocked method has been called at least once.
    #
    # @example
    #   my_mock = Grift.spy_on(MyClass, :my_method)
    #   MyClass.my_method
    #   assert_mock_called(my_mock)
    #
    # @param mock [Grift::MockMethod] the mock to be checked
    # @param msg [String, Proc] a message to show before the failure message
    #
    # @return [true]
    #
    def assert_mock_called(mock, msg = nil)
      refute mock.empty?, message(msg) { "Expected #{mock} to be called" }
    end

    ##
    # Asserts that the mocked method has not been called.
    #
    # @example
    #   my_mock = Grift.spy_on(MyClass, :my_method)
    #   refute_mock_called(my_mock)
    #
    # @param mock [Grift::MockMethod] the mock to be checked
    # @param msg [String, Proc] a message to show before the failure message
    #
    # @return [true]
    #
    def refute_mock_called(mock, msg = nil)
      failure = message(msg, '') do
        "Expected #{mock} to not be called, but it was called with:\n#{mock_calls_description(mock)}"
      end
      assert mock.empty?, failure
    end

    ##
    # Asserts that the mocked method has been called at least once with exactly the given arguments.
    # Every argument is matched against the calls, so there is no custom message parameter.
    #
    # @example
    #   my_mock = Grift.spy_on(MyClass, :my_method)
    #   MyClass.my_method('first', second: 2)
    #   assert_mock_called_with(my_mock, 'first', second: 2)
    #
    # @param mock [Grift::MockMethod] the mock to be checked
    # @param args [Array] the expected positional arguments
    # @param kwargs [Hash] the expected keyword arguments
    #
    # @return [true]
    #
    def assert_mock_called_with(mock, *args, **kwargs)
      failure = proc do
        expected = "Expected #{mock} to be called with #{mock_call_description(args, kwargs)}"
        if mock.empty?
          "#{expected}, but it was not called."
        else
          "#{expected}, but it was called with:\n#{mock_calls_description(mock)}"
        end
      end
      assert mock_called_with?(mock, args, kwargs), failure
    end

    ##
    # Asserts that the mocked method has not been called with exactly the given arguments.
    # Every argument is matched against the calls, so there is no custom message parameter.
    #
    # @example
    #   my_mock = Grift.spy_on(MyClass, :my_method)
    #   MyClass.my_method('first', second: 2)
    #   refute_mock_called_with(my_mock, 'first', second: 3)
    #
    # @param mock [Grift::MockMethod] the mock to be checked
    # @param args [Array] the positional arguments that should not have been used
    # @param kwargs [Hash] the keyword arguments that should not have been used
    #
    # @return [true]
    #
    def refute_mock_called_with(mock, *args, **kwargs)
      failure = proc { "Expected #{mock} to not be called with #{mock_call_description(args, kwargs)}." }
      refute mock_called_with?(mock, args, kwargs), failure
    end

    private

    ##
    # Checks if any call to the mock used exactly the given arguments.
    #
    # @return [Boolean]
    #
    def mock_called_with?(mock, args, kwargs)
      mock.calls.any? { |call| args == call.args && kwargs == call.kwargs }
    end

    ##
    # Formats the arguments of a call like they would be written in Ruby.
    #
    # @return [String]
    #
    def mock_call_description(args, kwargs)
      values = args.map { |arg| mu_pp(arg) } + kwargs.map { |key, value| "#{key}: #{mu_pp(value)}" }
      "(#{values.join(', ')})"
    end

    ##
    # Formats every call to the mock, one per line.
    #
    # @return [String]
    #
    def mock_calls_description(mock)
      mock.calls.map { |call| "  #{mock_call_description(call.args, call.kwargs)}" }.join("\n")
    end
  end
end
