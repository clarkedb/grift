# frozen_string_literal: true

module Grift
  class MockMethod
    ##
    # An Array wrapper that tracks the calls and results for a {Grift::MockMethod}.
    #
    class MockExecutions
      ##
      # A new instance of MockExecutions.
      #
      # @return [Grift::MockMethod::MockExectuions]
      #
      def initialize
        @executions = []
      end

      ##
      # Returns an array of the args used in each call to the mocked method
      #
      # @example
      #   my_mock = Grift.spy_on(Number, :+)
      #   x = (3 + 4) + 5
      #   my_mock.mock.calls
      #   #=> [[4], [5]]
      #
      # @return [Array<Array>] an array of arrays of args
      #
      def calls
        @executions.map do |exec|
          exec[:args]
        end
      end

      ##
      # Returns true if there have been no calls tracked.
      #
      # @example
      #   my_mock = Grift.mock(String, :upcase)
      #   my_mock.mock.empty?
      #   #=> true
      #   "apple".upcase
      #   #=> "APPLE"
      #   my_mock.mock.empty?
      #   #=> false
      #
      # @return [Boolean] if the executions are empty
      #
      def empty?
        @executions.empty?
      end

      ##
      # Returns the count of executions.
      #
      # @example
      #   my_mock = Grift.mock(String, :upcase)
      #   my_mock.mock.count
      #   #=> 0
      #   "apple".upcase
      #   #=> "APPLE"
      #   my_mock.mock.count
      #   #=> 1
      #
      # @return [Number] the number of executions
      #
      def count
        @executions.count
      end

      ##
      # Returns an array of the results of each call to the mocked method
      #
      # @example
      #   my_mock = Grift.spy_on(Number, :+)
      #   x = (3 + 4) + 5
      #   my_mock.mock.results
      #   #=> [7, 12]
      #
      # @return [Array] an array of results
      #
      def results
        @executions.map do |exec|
          exec[:result]
        end
      end

      ##
      # Stores an args and result pair to the executions array.
      #
      # @example
      #   mock_store = Grift::MockMethod::MockExecutions.new
      #   mock_store.store([1, 1], [2])
      #
      # @return [Array] an array of results
      #
      def store(args, result)
        @executions.push({ args: args, result: result })
      end
    end
  end
end
