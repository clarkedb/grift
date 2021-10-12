# frozen_string_literal: true

require 'grift/version'

module Grift
  class Error < StandardError; end

  #
  # The base class for all of Grift
  #
  class Base
    def self.mock(klass, func, _ret_value)
      puts "Not implemented, but this would mock #{func} on #{klass}"
    end
  end
end
