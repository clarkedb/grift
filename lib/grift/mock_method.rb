# frozen_string_literal: true

module Grift
  class MockMethod
    attr_reader :true_method_cached, :klass, :method_name

    CACHE_METHOD_PREFIX = 'grift_cache'

    def initialize(klass, method_name, watch: true)
      if Grift.restricted_method?(klass, method_name)
        raise(Grift::Error, "Cannont mock restricted method #{method_name} for class #{klass}")
      end

      @klass = klass
      @method_name = method_name
      @true_method_cached = false
      @mock_executions = MockExecutions.new
      @cache_method_name = "#{CACHE_METHOD_PREFIX}_#{method_name}".to_sym

      # class methods are really instance methods of the singleton class
      @class_method = klass.singleton_class.instance_methods(true).include?(method_name)

      unless class_instance.instance_methods(true).include?(method_name)
        raise(Grift::Error, "Cannont mock unknown method #{method_name} for class #{klass}")
      end

      if class_instance.instance_methods.include?(@cache_method_name)
        raise(Grift::Error, "Cannot mock already mocked method #{method_name} for class #{klass}")
      end

      watch_method if watch
    end

    def mock
      @mock_executions
    end

    def mock_clear
      @mock_executions = MockExecutions.new
    end

    def mock_reset
      mock_clear
      mock_return_value(nil)
    end

    def mock_restore(watch: false)
      mock_clear
      unmock_method if @true_method_cached
      watch_method if watch
    end

    def mock_implementation(&block)
      premock_setup
      mock_executions = @mock_executions # required to access inside class instance block

      class_instance.remove_method(@method_name)
      class_instance.define_method @method_name do |*args|
        return_value = block.call(*args)

        # record the args passed in the call to the method and the result
        mock_executions.store(args, return_value)
        return return_value
      end

      self
    end

    def mock_return_value(return_value = nil)
      premock_setup
      mock_executions = @mock_executions # required to access inside class instance block

      class_instance.remove_method(@method_name)
      class_instance.define_method @method_name do |*args|
        # record the args passed in the call to the method and the result
        mock_executions.store(args, return_value)
        return return_value
      end

      self
    end

    def to_s
      Grift::MockMethod.hash_key(@klass, @method_name)
    end

    def self.hash_key(klass, method_name)
      "#{klass}\##{method_name}"
    end

    private

    def watch_method
      premock_setup
      mock_executions = @mock_executions # required to access inside class instance block
      cache_method_name = @cache_method_name

      class_instance.remove_method(@method_name)
      class_instance.define_method @method_name do |*args|
        return_value = send(cache_method_name, *args)

        # record the args passed in the call to the method and the result
        mock_executions.store(args, return_value)
        return return_value
      end

      self
    end

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

    def premock_setup
      cache_method unless @true_method_cached
      send_to_store
    end

    def send_to_store
      Grift.mock_store.store(self) unless Grift.mock_store.include?(self)
    end

    def class_instance
      @class_method ? @klass.singleton_class : @klass
    end
  end
end
