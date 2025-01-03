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
      "#{klass}##{method_name}"
    end

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
      @cache_method_name = :"#{CACHE_METHOD_PREFIX}_#{method_name}"

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
    # mocks the method to return +nil+.
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
    #   my_mock = Grift.spy_on(MyClass, :my_method).mock_implementation do |first, second, **kwargs|
    #       [second, kwargs[:third], first]
    #   end
    #   MyClass.my_method(1, 2, third: 3)
    #   #=> [2, 3, 1]
    #
    # @return [self] the mock itself
    #
    def mock_implementation(*)
      raise(Grift::Error, 'Must provide a block for the new implementation') unless block_given?

      premock_setup
      mock_executions = @mock_executions # required to access inside class instance block

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args, **kwargs|
        return_value = yield(*args, **kwargs)

        # record the args passed in the call to the method and the result
        mock_executions.store(args: args, result: return_value)
        return_value
      end
      class_instance.send(@method_access, @method_name)

      self
    end

    ##
    # Accepts a block and mocks the method to execute that block instead
    # of the original behavior the next time the method is called while mocked.
    # After the method has been called once, it will return to its original
    # behavior. The method will continue to be watched.
    #
    # @see #mock_implementation
    #
    # @example
    #   my_mock = Grift.spy_on(String, :downcase).mock_implementation_once do
    #       x = 3 + 4
    #       x.to_s
    #   end
    #   ["Banana", "Apple"].map(&:downcase)
    #   #=> ["7", "apple"]
    #
    # @return [self] the mock itself
    #
    def mock_implementation_once(*)
      raise(Grift::Error, 'Must provide a block for the new implementation') unless block_given?

      premock_setup

      # required to access inside class instance block
      mock_executions = @mock_executions
      clean_mock = lambda do
        unmock_method
        watch_method
      end

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args, **kwargs|
        return_value = yield(*args, **kwargs)

        # record the args passed in the call to the method and the result
        mock_executions.store(args: args, result: return_value)

        clean_mock.call

        return_value
      end
      class_instance.send(@method_access, @method_name)

      self
    end

    ##
    # Accepts a number +n+ and a block and mocks the method to execute that block
    # instaead of the original behavior the next +n+ times the method is called
    # while mocked. After the method has been called once, it will return to its
    # original behavior. The method will continue to be watched.
    #
    # **IMPORANT:** Calling {#mock_clear} clears the method call history. If it is
    # called before the nth execution of the mocked method, the method will remain
    # mocked for an additonal +n+ calls.
    #
    # @see #mock_implementation
    #
    # @example
    #   my_mock = Grift.spy_on(String, :downcase).mock_implementation_n_times(3) do
    #       x = 3 + 4
    #       x.to_s
    #   end
    #   ["Banana", "Apple", "Orange", "Guava"].map(&:downcase)
    #   #=> ["7", "7", "7", "guava"]
    #
    # @example
    #   my_mock = Grift.spy_on(String, :downcase).mock_implementation_n_times(5) do
    #       x = 3 + 4
    #       x.to_s
    #   end
    #   ["Banana", "Apple", "Orange", "Guava"].map(&:downcase)
    #   #=> ["7", "7", "7", "7"]
    #   my_mock.mock_clear # clear mock history before 5th (nth) method call
    #   ["Banana", "Apple", "Orange", "Guava"].map(&:downcase)
    #   #=> ["7", "7", "7", "7"]
    #
    # @param n [Number] the number of times to mock the implementation
    #
    # @return [self] the mock itself
    #
    def mock_implementation_n_times(n, *)
      raise(Grift::Error, 'Must provide a block for the new implementation') unless block_given?

      premock_setup

      # required to access inside class instance block
      mock_executions = @mock_executions
      clean_mock = lambda do
        unmock_method
        watch_method
      end

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args, **kwargs|
        return_value = yield(*args, **kwargs)

        # record the args passed in the call to the method and the result
        mock_executions.store(args: args, result: return_value)

        clean_mock.call if mock_executions.count == n

        return_value
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
    # @return [self] the mock itself
    #
    def mock_return_value(return_value = nil)
      premock_setup
      mock_executions = @mock_executions # required to access inside class instance block

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args, **kwargs|
        # record the args passed in the call to the method and the result
        mock_executions.store(args: args, kwargs: kwargs, result: return_value)
        return_value
      end
      class_instance.send(@method_access, @method_name)

      self
    end

    ##
    # Accepts a value and mocks the method to return that value once instead
    # of executing its original behavior while mocked. After the method has
    # been called once, it will return to its original behavior. The method
    # will continue to be watched.
    #
    # @example
    #   my_mock = Grift.spy_on(String, :upcase).mock_return_value_once("BANANA")
    #   ["apple", "apple"].map(&:upcase)
    #   #=> ["BANANA", "APPLE"]
    #
    # @param return_value the value to return from the method once
    #
    # @return [self] the mock itself
    #
    def mock_return_value_once(return_value = nil)
      premock_setup

      # required to access mock inside class instance block
      mock_executions = @mock_executions
      clean_mock = lambda do
        unmock_method
        watch_method
      end

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args, **kwargs|
        # record the args passed in the call to the method and the result
        mock_executions.store(args: args, kwargs: kwargs, result: return_value)

        clean_mock.call

        return_value
      end
      class_instance.send(@method_access, @method_name)

      self
    end

    ##
    # Accepts a value and mocks the method to return that value +n+ times instead
    # of executing its original behavior while mocked. After the method has
    # been called +n+ times, it will return to its original behavior. The method
    # will continue to be watched.
    #
    # **IMPORANT:** Calling {#mock_clear} clears the method call history. If it is
    # called before the nth execution of the mocked method, the method will remain
    # mocked for an additional +n+ calls.
    #
    # @example
    #   my_mock = Grift.spy_on(String, :upcase).mock_return_value_n_times(2, "BANANA")
    #   ["apple", "apple", "apple"].map(&:upcase)
    #   #=> ["BANANA", "BANANA", "APPLE"]
    #
    # @example
    #   my_mock = Grift.spy_on(String, :upcase).mock_return_value_n_times(4, "BANANA")
    #   ["apple", "apple", "apple"].map(&:upcase)
    #   #=> ["BANANA", "BANANA", "BANANA"]
    #   my_mock.mock_clear # clear mock history before 4th (nth) method call
    #   ["apple", "apple", "apple"].map(&:upcase)
    #   #=> ["BANANA", "BANANA", "BANANA"]
    #
    # @param n [Number] the number of times to mock the return value
    # @param return_value the value to return from the method +n+ times
    #
    # @return [self] the mock itself
    #
    def mock_return_value_n_times(n, return_value = nil)
      premock_setup

      # required to access mock inside class instance block
      mock_executions = @mock_executions
      clean_mock = lambda do
        unmock_method
        watch_method
      end

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args, **kwargs|
        # record the args passed in the call to the method and the result
        mock_executions.store(args: args, kwargs: kwargs, result: return_value)

        clean_mock.call if mock_executions.count == n

        return_value
      end
      class_instance.send(@method_access, @method_name)

      self
    end

    ##
    # Accepts an array of values and mocks the method to return those values
    # in order instead of executing its original behavior while mocked. After
    # the method has been called enough times to return each of the values,
    # it will return to its original behavior. The method continue to be watched.
    #
    # @example
    #   mock_values = ["APPLE", "BANANA", "ORANGE"]
    #   my_mock = Grift.spy_on(String, :upcase).mock_return_values_in_order(mock_values)
    #   ["pineapple", "orange", "guava", "mango", "watermelon"].map(&:upcase)
    #   #=> ["APPLE", "BANANA", "ORANGE", "MANGO", "WATERMELON"]
    #
    # @param return_values [Array] the values to return from the method in order
    #
    # @return [self] the mock itself
    #
    def mock_return_values_in_order(return_values)
      unless return_values.is_a?(Array) && !return_values.empty?
        raise(Grift::Error, 'Must provide a non-empty array for the return values')
      end

      premock_setup

      # required to access mock inside class instance block
      mock_executions = @mock_executions
      clean_mock = lambda do
        unmock_method
        watch_method
      end
      return_values_internal = return_values.dup

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args, **kwargs|
        # record the args passed in the call to the method and the result
        return_value = return_values_internal.shift
        mock_executions.store(args: args, kwargs: kwargs, result: return_value)

        clean_mock.call if return_values_internal.empty?

        return_value
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
    # Returns an array of the args used in each call to the mocked method
    # This is syntactical sugar equivalent to calling +mock+ and then +calls+.
    #
    # @see Grift::MockMethod::MockExecutions#calls
    #
    # @example
    #   my_mock = Grift.spy_on(Number, :+)
    #   x = (3 + 4) + 5
    #   my_mock.calls.map(&:values)
    #   #=> [[4], [5]]
    #
    # @return [Array<Grift::MockMethod::MockExecutions::MockArguments>] an array of MockArguments
    #
    def calls
      @mock_executions.calls
    end

    ##
    # Returns true if there have been no calls to the mock.
    # This is syntactical sugar equivalent to calling +mock+ and then +empty?+.
    #
    # @see Grift::MockMethod::MockExecutions#empty?
    #
    # @example
    #   my_mock = Grift.mock(String, :upcase)
    #   my_mock.mock.empty?
    #   #=> true
    #   "apple".upcase
    #   #=> "APPLE"
    #   my_mock.empty?
    #   #=> false
    #
    # @return [Boolean] if the executions are empty
    #
    def empty?
      @mock_executions.empty?
    end

    ##
    # Returns the count of mock executions.
    # This is syntactical sugar equivalent to calling +mock+ and then +count+.
    #
    # @see Grift::MockMethod::MockExecutions#count
    #
    # @example
    #   my_mock = Grift.mock(String, :upcase)
    #   my_mock.mock.count
    #   #=> 0
    #   "apple".upcase
    #   #=> "APPLE"
    #   my_mock.count
    #   #=> 1
    #
    # @return [Number] the number of executions
    #
    def count
      @mock_executions.count
    end

    ##
    # Returns an array of the results of each call to the mocked method
    # This is syntactical sugar equivalent to calling +mock+ and then +results+.
    #
    # @see Grift::MockMethod::MockExecutions#results
    #
    # @example
    #   my_mock = Grift.spy_on(Number, :+)
    #   x = (3 + 4) + 5
    #   my_mock.results
    #   #=> [7, 12]
    #
    # @return [Array] an array of results
    #
    def results
      @mock_executions.results
    end

    private

    ##
    # Watches the method without mocking its impelementation or return value.
    #
    # @return [self] the mock itself
    #
    def watch_method
      premock_setup
      mock_executions = @mock_executions # required to access inside class instance block
      cache_method_name = @cache_method_name

      class_instance.remove_method(@method_name) if !@inherited && method_defined?
      class_instance.define_method @method_name do |*args, **kwargs, &block|
        return_value = send(cache_method_name, *args, **kwargs, &block)

        # record the args passed in the call to the method and the result
        mock_executions.store(args: args, kwargs: kwargs, result: return_value)
        return_value
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
    # Returns +nil+ if no definition for the method is found.
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
