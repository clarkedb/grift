# frozen_string_literal: true

module Grift
  ##
  # A mock for a given class and method. This is the core of Grift. Mocking or spying
  # usually returns a {Grift::MockMethod}.
  #
  class MockMethod
    attr_reader :true_method_cached, :klass, :method_name, :method_access

    CACHE_METHOD_PREFIX = 'grift_cache'
    private_constant :CACHE_METHOD_PREFIX

    ##
    # A new instance of MockMethod. Should be initialized via {Grift.mock} or {Grift.spy_on}
    #
    # @see Grift.mock
    # @see Grift.spy_on
    #
    # @example
    #   Grift.spy_on(MyClass, :my_method)
    #   #=> MockMethod instance with the method being watched
    #
    # @param klass [Class] the class to be mocked
    # @param method_name [Symbol] the method to be mocked
    # @param watch [Boolean] whether to start watching the method
    #
    # @return [Grift::MockMethod]
    #
    def initialize(klass, method_name, watch: true)
      if Grift.restricted_method?(klass, method_name)
        raise(Grift::Error, "Cannot mock restricted method #{method_name} for class #{klass}")
      end

      @klass = klass
      @method_name = method_name
      @true_method_cached = false
      @mock_executions = MockExecutions.new
      @cache_method_name = "#{CACHE_METHOD_PREFIX}_#{method_name}".to_sym

      # class methods are really instance methods of the singleton class
      @class_method = klass.singleton_class.method_defined?(method_name, true) ||
        klass.singleton_class.private_method_defined?(method_name, true)

      @method_access, @inherited = method_access_definition
      raise(Grift::Error, "Cannot mock unknown method #{method_name} for class #{klass}") unless @method_access

      if class_instance.method_defined?(@cache_method_name)
        raise(Grift::Error, "Cannot mock already mocked method #{method_name} for class #{klass}")
      end

      watch_method if watch
    end

    ##
    # Gets the data for the mock results and calls for this mock.
    #
    # @see Grift::MockMethod::MockExecutions#calls
    # @see Grift::MockMethod::MockExecutions#results
    #
    # @example
    #   my_mock = Grift.spy_on(String, :upcase)
    #   "banana".upcase
    #   #=> 'BANANA'
    #   my_mock.mock.calls
    #   #=> [[]]
    #   my_mock.mock.results
    #   #=> [['BANANA']]
    #
    # @return [Grift::MockMethod::MockExecutions]
    #
    def mock
      @mock_executions
    end

    ##
    # Clears the mock execution and calls data for this mock, but
    # keep the method mocked as before.
    #
    # @return [Grift::MockMethod::MockExecutions]
    #
    def mock_clear
      @mock_executions = MockExecutions.new
    end

    ##
    # Clears the mock execution and calls data for this mock, and
    # mocks the method to return `nil`.
    #
    # @return [Grift::MockMethod::MockExecutions]
    #
    def mock_reset
      executions = mock_clear
      mock_return_value(nil)
      executions
    end

    ##
    # Clears the mock execution and calls data for this mock, and
    # restores the method to its original behavior. By default it
    # also stops watching the method. This cleans up the mocking
    # and restores expected behavior.
    #
    # @param watch [Boolean] whether or not to keep watching the method
    #
    # @return [Grift::MockMethod::MockExecutions]
    #
    def mock_restore(watch: false)
      executions = mock_clear
      unmock_method if @true_method_cached
      watch_method if watch
      executions
    end

    ##
    # Accepts a block and mocks the method to execute that block instead
    # of the original behavior whenever called while mocked.
    #
    # @example
    #   my_mock = Grift.spy_on(String, :downcase).mock_implementation do
    #       x = 3 + 4
    #       x.to_s
    #   end
    #   "Banana".downcase
    #   #=> '7'
    #
    # @example
    #   my_mock = Grift.spy_on(MyClass, :my_method).mock_implementation do |first, second|
    #       [second, first]
    #   end
    #   MyClass.my_method(1, 2)
    #   #=> [2, 1]
    #
    # @return [Grift::MockMethod] the mock itself
    #
    def mock_implementation(*)
      premock_setup
      mock_executions = @mock_executions # required to access inside class instance block

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args|
        return_value = yield(*args)

        # record the args passed in the call to the method and the result
        mock_executions.store(args, return_value)
        return return_value
      end
      class_instance.send(@method_access, @method_name)

      self
    end

    ##
    # Accepts a value and mocks the method to return that value instead
    # of executing its original behavior while mocked.
    #
    # @see Grift#mock
    #
    # @example
    #   my_mock = Grift.spy_on(String, :upcase).mock_return_value('BANANA')
    #   "apple".upcase
    #   #=> 'BANANA'
    #
    # @param return_value the value to return from the method
    #
    # @return [Grift::MockMethod] the mock itself
    #
    def mock_return_value(return_value = nil)
      premock_setup
      mock_executions = @mock_executions # required to access inside class instance block

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args|
        # record the args passed in the call to the method and the result
        mock_executions.store(args, return_value)
        return return_value
      end
      class_instance.send(@method_access, @method_name)

      self
    end

    ##
    # String representation of the MockMethod
    #
    # @see Grift::MockMethod.hash_key
    #
    # @return [String]
    #
    def to_s
      Grift::MockMethod.hash_key(@klass, @method_name)
    end

    ##
    # Hashes the class and method for tracking mocks.
    #
    # @example
    #   Grift::MockMethod.hash_key(String, :upcase)
    #   #=> 'String#upcase'
    #
    # @param klass [Class]
    # @param method_name [Symbol]
    #
    # @return [String] the hash of the class and method
    #
    def self.hash_key(klass, method_name)
      "#{klass}\##{method_name}"
    end

    private

    ##
    # Watches the method without mocking its impelementation or return value.
    #
    # @return [Grift::MockMethod] the mock itself
    #
    def watch_method
      premock_setup
      mock_executions = @mock_executions # required to access inside class instance block
      cache_method_name = @cache_method_name

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args|
        return_value = send(cache_method_name, *args)

        # record the args passed in the call to the method and the result
        mock_executions.store(args, return_value)
        return return_value
      end
      class_instance.send(@method_access, @method_name)

      self
    end

    ##
    # Unmocks the method and restores the true method
    #
    # @raise [Grift:Error] if method not mocked
    #
    def unmock_method
      raise(Grift::Error, 'Method is not cached') unless @true_method_cached

      class_instance.remove_method(@method_name) if method_defined?
      class_instance.alias_method(@method_name, @cache_method_name) unless @inherited
      class_instance.remove_method(@cache_method_name)

      @true_method_cached = false
    end

    ##
    # Caches the method
    #
    # @raise [Grift::Error] if method already cached
    #
    def cache_method
      raise(Grift::Error, 'Method already cached') if @true_method_cached

      class_instance.alias_method(@cache_method_name, @method_name)
      @true_method_cached = true
    end

    ##
    # Sets up mock actions by caching the method and storing it in the
    # Grift global store.
    #
    def premock_setup
      cache_method unless @true_method_cached
      send_to_store
    end

    ##
    # Adds the mock to the global store
    #
    def send_to_store
      Grift.mock_store.store(self) unless Grift.mock_store.include?(self)
    end

    ##
    # Returns the appropriate class instance
    #
    # @return [Class]
    #
    def class_instance
      @class_method ? @klass.singleton_class : @klass
    end

    ##
    # Checks if the method is defined on the class instance. If the method is
    # inherited from the super class and has not been mocked yet, this will
    # return false because the super class defined the method.
    #
    # @return [Boolean]
    #
    def method_defined?
      class_instance.instance_methods(false).include?(@method_name) ||
        class_instance.private_instance_methods(false).include?(@method_name)
    end

    ##
    # Checks for the original access of the method (public, protected, private),
    # and if that definition is inherited from an ancestor (super) class.
    # Returns `nil` if no definition for the method is found.
    #
    # @return [Symbol] the method access
    # @return [Boolean] true if the method is inherited
    #
    def method_access_definition
      if class_instance.public_method_defined?(@method_name, true)
        [:public, !class_instance.public_method_defined?(@method_name, false)]
      elsif class_instance.protected_method_defined?(@method_name, true)
        [:protected, !class_instance.protected_method_defined?(@method_name, false)]
      elsif class_instance.private_method_defined?(@method_name, true)
        [:private, !class_instance.private_method_defined?(@method_name, false)]
      end
    end
  end
end
