# frozen_string_literal: true

module Grift
  class MockMethod
    CACHE_METHOD_PREFIX = 'grift_cache'

    def initialize(klass, method_name)
      @klass = klass
      @method_name = method_name
      @true_method_cached = false
      @mock_executions = MockExecutions.new
      @cache_method_name = "#{CACHE_METHOD_PREFIX}_#{method_name}".to_sym

      # class methods are really instance methods of the singleton class
      @class_method = klass.singleton_class.instance_methods(true).include?(method_name)
    end

    def mock
      @mock_executions
    end

    def mock_clear
      @mock_executions = MockExecutions.new
    end

    def mock_reset
      mock_clear
      mock_return_value
    end

    def mock_restore
      mock_clear
      unmock_method if @true_method_cached
    end

    def mock_implementation(&block)
      raise NotImplementedError
    end

    def mock_return_value(return_value = nil)
      cache_method unless @true_method_cached
      mock_executions = @mock_executions # required to access inside class instance block

      class_instance.remove_method(@method_name)
      class_instance.define_method @method_name do |*args|
        # record the args passed in the call to the method and the result
        mock_executions.store(args, return_value)

        return return_value
      end

      self
    end

    private

    def unmock_method
      raise(Grift::Error, 'Method is not cached') unless @true_method_cached

      class_instance.remove_method(@method_name)
      class_instance.alias_method(@method_name, @cache_method_name)
      class_instance.remove_method(@cache_method_name)

      @true_method_cached = false
    end

    def cache_method
      raise(Grift::Error, 'Method already cached') if @true_method_cached

      class_instance.alias_method(@cache_method_name, @method_name)
      @true_method_cached = true
    end

    def class_instance
      @class_method ? @klass.singleton_class : @klass
    end
  end
end
