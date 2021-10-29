# frozen_string_literal: true

module Grift
  module MinitestPlugin
    def after_teardown
      super
      Grift.restore_all_mocks(watch: false)
    end
  end
end
