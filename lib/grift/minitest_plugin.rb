# frozen_string_literal: true

module Grift
  ##
  # A plugin to clean up mocks after tests in Minitest.
  # It is recommended that you include this plugin to avoid
  # needing to cleanup the mocks after each test.
  #
  # To setup the plugin for your tests, you should include the
  # following code in your +test_helper+
  #
  #   class Minitest::Test
  #     include Grift::MinitestPlugin
  #   end
  #
  module MinitestPlugin
    ##
    # After each test restores all mocks with no watching.
    #
    # @return [Grift::MockStore]
    #
    def after_teardown
      super
      Grift.restore_all_mocks(watch: false)
    end
  end
end
