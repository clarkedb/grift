# frozen_string_literal: true

module Grift
  class MockStore
    def initialize
      @mocks = {}
    end

    def store(mock_method)
      raise(Grift::Error, 'Must only store Grift Mocks') unless mock_method.instance_of?(Grift::MockMethod)
      raise(Grift::Error, 'Store aready contains that mock') if include?(mock_method)

      @mocks[mock_method.to_s] = mock_method
    end

    def mocks(klass: nil, method: nil)
      search(klass: klass, method: method).values
    end

    def remove(klass: nil, method: nil)
      to_remove = search(klass: klass, method: method)
      to_remove.each do |key, mock|
        mock.mock_restore(watch: false)
        @mocks.delete(key)
      end
    end

    def delete(mock_method)
      if include?(mock_method)
        mock_method.mock_restore(watch: false)
        @mocks.delete(mock_method.to_s)
      end

      self
    end

    def include?(search_value)
      @mocks.include?(search_value.to_s)
    end

    def empty?
      @mocks.empty?
    end

    private

    def search(klass: nil, method: nil)
      return @mocks unless klass || method

      pattern = Regexp.new(Grift::MockMethod.hash_key(klass, method))
      # rubocop:disable Style/SelectByRegexp
      @mocks.select { |k| pattern.match?(k) }
      # rubocop:enable Style/SelectByRegexp
    end
  end
end
