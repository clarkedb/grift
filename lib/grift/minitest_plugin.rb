# frozen_string_literal: true

module Grift
  module MinitestPlugin
    def before_teardown
      super
      Grift.restore_all_mocks(watch: false)
    end
  end
end
