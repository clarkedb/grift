# frozen_string_literal: true

module Grift
  class MockMethod
    class MockExecutions
      def initialize
        @executions = []
      end

      def calls
        @executions.map do |exec|
          exec[:args]
        end
      end

      def empty?
        @executions.empty?
      end

      def count
        @executions.count
      end

      def results
        @executions.map do |exec|
          exec[:result]
        end
      end

      def store(args, result)
        @executions.push(
          {
            args: args,
            result: result
          }
        )
      end
    end
  end
end
