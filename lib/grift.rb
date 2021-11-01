# frozen_string_literal: true

require 'grift/error'
require 'grift/minitest_plugin'
require 'grift/mock_method'
require 'grift/mock_method/mock_executions'
require 'grift/mock_store'
require 'grift/version'

module Grift
  @mock_store = Grift::MockStore.new

  class << self
    attr_reader :mock_store

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
    def mock(klass, method, return_value = nil)
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
      hash_key = Grift::MockMethod.hash_key(klass, method)
      @mock_store.include?(hash_key)
    end

    def clear_mocks(klass)
      @mock_store.mocks(klass: klass).each(&:mock_clear)
    end

    def reset_mocks(klass)
      @mock_store.mocks(klass: klass).each(&:mock_reset)
    end

    def restore_mocks(klass, watch: false)
      if watch
        @mock_store.mocks(klass: klass).each { |m| m.mock_restore(watch: true) }
      else
        @mock_store.remove(klass: klass)
      end
    end

    def clear_all_mocks
      @mock_store.mocks.each(&:mock_clear)
    end

    def reset_all_mocks
      @mock_store.mocks.each(&:mock_reset)
    end

    def restore_all_mocks(watch: false)
      if watch
        @mock_store.mocks.each { |m| m.mock_restore(watch: true) }
      else
        @mock_store.remove
      end
    end
  end
end
