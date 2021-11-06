# frozen_string_literal: true

require 'yaml'

module Grift
  ##
  # The config for Grift. This is readonly for now.
  #
  module Config
    @restricted_methods = YAML.safe_load(File.read('lib/grift/config/restricted.yml'))

    class << self
      ##
      # The restricted methods as a hash organized by class as the key and then the
      # methods in an array as the value. A '*' means all methods are restricted.
      # A '^' preceding a method overrides the wildcard restriction.
      #
      # @example
      #   Grift::Config.restricted_methods
      #   #=> { 'Class' => ['method1', ...], ... }
      #
      # @return [Hash] the restricted methods organized by class
      #
      attr_reader :restricted_methods
    end
  end
end
