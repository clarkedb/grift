# frozen_string_literal: true

require 'grift/error'
require 'grift/mock_cache'
require 'grift/mock_method'
require 'grift/mock_method/mock_executions'
require 'grift/version'

module Grift
  class << self
    ##
    # Mocks the given method to return the provided value.
    # This is syntactical sugar equivalent to calling
    # `spy_on` and then `mock_return_value`.
    #
    # @return [Grift::MockMethod]
    #
    # @example
    #   Grift.mock(MyClass, :some_method, true)
    #
    def mock(klass, method, return_value)
      spy_on(klass, method).mock_return_value(return_value)
    end

    ##
    # Creates a mock for the given method without mocking
    # the implementation or return values.
    #
    # @return [Grift::MockMethod]
    #
    # @example
    #   Grift.spy_on(MyClass, :some_method)
    #
    def spy_on(klass, method)
      MockMethod.new(klass, method)
    end

    def mock_method?(klass, method)
      raise NotImplentedError
    end

    def clear_mocks(klass)
      raise NotImplentedError
    end

    def reset_mocks(klass)
      raise NotImplentedError
    end

    def restore_mocks(klass)
      raise NotImplentedError
    end

    def clear_all_mocks
      raise NotImplentedError
    end

    def reset_all_mocks
      raise NotImplentedError
    end

    def restore_all_mocks
      raise NotImplentedError
    end
  end
end
