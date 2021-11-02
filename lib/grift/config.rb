# frozen_string_literal: true

require 'yaml'

module Grift
  module Config
    @restricted_methods = YAML.safe_load(File.read('lib/grift/config/restricted.yml'))

    class << self
      attr_reader :restricted_methods
    end
  end
end
