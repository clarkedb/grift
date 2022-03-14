# frozen_string_literal: true

module Grift
  class MockMethod
    class MockExecutions
      ##
      # An immutable Enumerable that stores the arguments used in a call for {Grift::MockMethod::MockExecutions}.
      #
      class MockArguments
        include Enumerable

        attr_reader :args, :kwargs

        ##
        # A new instance of MockArguments.
        #
        # @return [Grift::MockMethod::MockExecutions::MockArguments]
        #
        def initialize(args: [], kwargs: {})
          @args = args.freeze
          @kwargs = kwargs.freeze
        end

        ##
        # Retrieves a stored argument by an accessor. For positional arguments this would be an integer
        # corresponding to the arguments position in the method call signature. For keyword arguments
        # this would be the key / parameter name as a symbol or string.
        #
        # @example
        #   my_mock = Grift.mock(Request, :new)
        #   request = Request.new('/users', method: 'GET')
        #   #=> <Request object>
        #   my_mock.mock.calls.last[0] # integer access for positional
        #   #=> '/users'
        #   my_mock.mock.calls.last[:method] # key access for keyword
        #   #=> 'GET'
        #
        # @param index [Integer, Symbol, String] the accessor for the desired argument
        #
        # @raise [Grift::Error] exception if accessor is not a supported type
        #
        # @return the specified value
        #
        def [](index)
          if index.instance_of?(Integer)
            @args[index]
          elsif index.instance_of?(Symbol)
            @kwargs[index]
          elsif index.instance_of?(String)
            @kwargs[index.to_sym]
          else
            raise(Grift::Error, "Cannot access by type '#{index.class}'. Expected an Integer, Symbol, or String")
          end
        end

        ##
        # Calls the given block once for each argument value, passing that value
        # as a parameter.
        #
        # @return [void]
        #
        def each(&block)
          @args.each(&block)
          @kwargs.each_value(&block)
        end

        ##
        # @see Enumerable#first
        #
        # Returns the last argument passed in the call.
        #
        # @example
        #   my_mock = Grift.mock(Request, :new)
        #   request = Request.new('/users', method: 'GET')
        #   #=> <Request object>
        #   my_mock.mock.calls.last.last
        #   #=> 'GET'
        #
        # @return [Any]
        #
        def last
          @args.last || @kwargs.values.last
        end

        ##
        # Returns the number of arguments passed in the call.
        #
        # @example
        #   arr = [1, 2, 3]
        #   my_mock = Grift.mock(Array, :count)
        #   arr.count
        #   #=> 3
        #   my_mock.mock.calls.last.length
        #   #=> 0
        #   arr.count(3)
        #   #=> 1
        #   my_mock.mock.calls.last.length
        #   #=> 1
        #
        # @return [Integer]
        #
        def length
          @args.length + @kwargs.length
        end

        ##
        # Returns true if the call included no arguments.
        #
        # @example
        #   arr = [1, 2, 3]
        #   my_mock = Grift.mock(Array, :count)
        #   arr.count
        #   #=> 3
        #   my_mock.mock.calls.last.empty?
        #   #=> true
        #   arr.count(2)
        #   #=> 1
        #   my_mock.mock.calls.last.empty?
        #   #=> false
        #
        # @return [Boolean] true if the no arguments were used
        #
        def empty?
          @args.empty? && @kwargs.empty?
        end

        ##
        # Returns the keyword parameter keys passed in the call.
        #
        # To get the values, use {Grift::MockMethod::MockExecutions::MockArguments#values}.
        #
        # @example
        #   my_mock = Grift.mock(Request, :new)
        #   request = Request.new('/users', method: 'GET')
        #   #=> <Request object>
        #   my_mock.mock.calls.last.keys
        #   #=> [:method]
        #
        # @return [Array<Symbol>] the parameter keys
        #
        def keys
          @kwargs.keys
        end

        ##
        # Returns the arguments passed in the call.
        #
        # If a keyword argument was used, then only the value will be returned.
        # To get the keys, use {Grift::MockMethod::MockExecutions::MockArguments#keys}.
        #
        # @example
        #   my_mock = Grift.mock(Request, :new)
        #   request = Request.new('/users', method: 'GET')
        #   #=> <Request object>
        #   my_mock.mock.calls.last.keys
        #   #=> [:method]
        #
        # @return [Array] the argument values
        #
        def values
          @args + @kwargs.values
        end
      end
    end
  end
end
