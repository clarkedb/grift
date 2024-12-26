# frozen_string_literal: true

require 'grift/config'
require 'grift/error'
require 'grift/minitest_plugin'
require 'grift/mock_method'
require 'grift/mock_method/mock_executions'
require 'grift/mock_method/mock_executions/mock_arguments'
require 'grift/mock_store'
require 'grift/version'

##
# The base of the gem. Nearly all interactions with Grift should occur
# through this base module.
#
module Grift
  class << self
    # @example
    #   Grift.mock_store
    # @return [Grift::MockStore] the current store of mocked methods scoped to the thread
    def mock_store
      Thread.current[:grift_internal_mock_store] ||= Grift::MockStore.new
    end

    ##
    # Mocks the given method to return the provided value.
    # This is syntactical sugar equivalent to calling
    # +spy_on+ and then +mock_return_value+.
    #
    # @example
    #   my_mock = Grift.mock(MyClass, :some_method, true)
    #
    # @param klass [Class] the class of the method to be mocked
    # @param method [Symbol] the symbol representing the method to be mocked
    # @param return_value the value the method should return while mocked
    #
    # @raise [Grift::Error] exception if method is already mocked or does not exist
    #
    # @return [Grift::MockMethod]
    #
    def mock(klass, method, return_value = nil)
      spy_on(klass, method).mock_return_value(return_value)
    end

    ##
    # Creates a mock for the given method without mocking
    # the implementation or return values.
    #
    # @example
    #   my_mock = Grift.spy_on(MyClass, :some_method)
    #
    # @param klass [Class] the class of the method to be watched
    # @param method [Symbol] the symbol representing the method to be watched
    #
    # @raise [Grift::Error] exception if method is already mocked or does not exist
    #
    # @return [Grift::MockMethod]
    #
    def spy_on(klass, method)
      MockMethod.new(klass, method)
    end

    ##
    # Checks whether the given method is currently mocked.
    #
    # @example
    #   Grift.mock(String, :upcase, 'STRING')
    #   Grift.mock_method?(String, :upcase)
    #   #=> true
    #
    # @example
    #   Grift.mock_method?(String, :downcase)
    #   #=> false
    #
    # @param klass [Class] the class of the method to be checked
    # @param method [Symbol] the symbol representing the method to be checked
    #
    # @return [Boolean] true if method is currently mocked
    #
    def mock_method?(klass, method)
      hash_key = Grift::MockMethod.hash_key(klass, method)
      mock_store.include?(hash_key)
    end

    ##
    # Checks whether the given method is restricted from being mocked.
    # For the list of restricted methods see {Grift::Config#restricted_methods}.
    #
    # @see Grift::Config#restricted_methods
    #
    # @example
    #   Grift.restricted_method?(Grift, :mock)
    #   #=> true
    #
    # @example
    #   Grift.restricted_method?(String, :upcase)
    #   #=> false
    #
    # @param klass [Class] the class of the method to be checked
    # @param method [Symbol] the symbol representing the method to be checked
    #
    # @return [Boolean] true if method cannot be mocked by Grift
    #
    def restricted_method?(klass, method)
      base_klass = klass.to_s.split('::').first
      klass_config = Grift::Config.restricted_methods[base_klass]
      return false unless klass_config

      (klass_config.include?('*') && !klass_config.include?("^#{method}")) || klass_config.include?(method.to_s)
    end

    ##
    # Clear the mocks of methods for a single class. Returns an array of the
    # new state of mock executions for the class after clearing.
    #
    # @example
    #   Grift.clear_mocks(MyClass)
    #
    # @param klass [Class] the class for which to clear mocks
    #
    # @return [Array<Grift::MockMethod::MockExecutions>]
    #
    def clear_mocks(klass)
      mock_store.mocks(klass: klass).each(&:mock_clear)
    end

    ##
    # Clear the mocks of methods for all classes. Returns an array of the
    # new state of mock executions for all mocks.
    #
    # @example
    #   Grift.clear_all_mocks
    #
    # @return [Array<Grift::MockMethod::MockExecutions>]
    #
    def clear_all_mocks
      mock_store.mocks.each(&:mock_clear)
    end

    ##
    # Reset the mocks of methods for a single class. Returns an array of the
    # new state of mock executions for the class after resetting.
    #
    # @example
    #   Grift.reset_mocks(MyClass)
    #
    # @param klass [Class] the class for which to reset mocks
    #
    # @return [Array<Grift::MockMethod::MockExecutions>]
    #
    def reset_mocks(klass)
      mock_store.mocks(klass: klass).each(&:mock_reset)
    end

    ##
    # Reset the mocks of methods for all classes. Returns an array of the
    # new state of mock executions for all mocks.
    #
    # @example
    #   Grift.reset_all_mocks
    #
    # @return [Array<Grift::MockMethod::MockExecutions>]
    #
    def reset_all_mocks
      mock_store.mocks.each(&:mock_reset)
    end

    ##
    # Restore the mocks of methods for a single class. Returns an array of the
    # new state of mock executions for the class after restoring.
    #
    # @example
    #   Grift.restore_mocks(MyClass)
    #   #=> restores mocks and stops watching them
    # @example
    #   Grift.restore_mocks(MyClass, watch: true)
    #   #=> restores mocks but keeps watching them
    #
    # @param klass [Class] the class for which to restore mocks
    # @param watch [Boolean] if true, keep watching the methods
    #
    # @return [Array<Grift::MockMethod::MockExecutions>]
    #
    def restore_mocks(klass, watch: false)
      if watch
        mock_store.mocks(klass: klass).each { |m| m.mock_restore(watch: true) }
      else
        mock_store.remove(klass: klass)
      end
    end

    ##
    # Restore the mocks of methods for all classes. Returns an array of the
    # new state of mock executions for all mocks.
    #
    # @example
    #   Grift.restore_mocks
    #   #=> restores all mocks and stops watching them
    # @example
    #   Grift.restore_mocks(watch: true)
    #   #=> restores all mocks but keeps watching them
    #
    # @param watch [Boolean] if true, keep watching the methods
    #
    # @return [Array<Grift::MockMethod::MockExecutions>, Grift::MockStore]
    #
    def restore_all_mocks(watch: false)
      if watch
        mock_store.mocks.each { |m| m.mock_restore(watch: true) }
      else
        mock_store.remove
      end
    end
  end
end
