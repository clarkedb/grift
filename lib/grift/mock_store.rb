# frozen_string_literal: true

module Grift
  ##
  # A hash wrapper that tracks what methods are mocked and facilitates cleanup of mocks.
  # This class is meant for internal use and should generally not be called explcitly.
  #
  class MockStore
    # A new instance of MockStore
    # @return [Grift::MockStore]
    def initialize
      @mocks = {}
    end

    ##
    # Add the given mock to the mock store.
    #
    # @example
    #   mock_store = Grift::MockStore.new
    #   mock_method = Grift.mock(MyClass, :my_method)
    #   mock_store.store(mock_method)
    #
    # @param mock_method [Grift::MockMethod] the mock method to add to the store
    #
    # @raise [Grift::Error] if mock_method is not of type {Grift::MockMethod}
    # @raise [Grift::Error] if the store already contains that mock or an equivalent mock
    #
    # @return [Grift::MockMethod] the mock method that was added
    #
    def store(mock_method)
      raise(Grift::Error, 'Must only store Grift Mocks') unless mock_method.instance_of?(Grift::MockMethod)
      raise(Grift::Error, 'Store aready contains that mock') if include?(mock_method)

      @mocks[mock_method.to_s] = mock_method
    end

    ##
    # Searches for the mock in the store. Optional filtering by class/method.
    # If no parameters are passed in, this returns all mocks in the store.
    #
    # @param klass [Class] the class to filter by, if nil all classes are included
    # @param method [Symbol] the method to filter by, if nil all symbols are included
    #
    # @return [Array] the mocks in the store that match the criteria
    #
    def mocks(klass: nil, method: nil)
      search(klass: klass, method: method).values
    end

    ##
    # Unmocks and removes mocks in the store. Optional filtering by class/method.
    # If no parameters are passed in, cleans up all mocks in the store.
    #
    # @param klass [Class] the class to filter by, if nil all classes are included
    # @param method [Symbol] the method to filter by, if nil all symbols are included
    #
    # @return [Grift::MockStore] the updated mock store itself
    #
    def remove(klass: nil, method: nil)
      to_remove = search(klass: klass, method: method)
      to_remove.each do |key, mock|
        mock.mock_restore(watch: false)
        @mocks.delete(key)
      end

      self
    end

    ##
    # Unmocks and removes the mock in the store. If the mock is not in the store,
    # nothing will change.
    #
    # @param mock_method [Grift::MockMethod, String] the mock to remove or its hash key
    #
    # @return [Grift::MockStore] the updated mock store itself
    #
    def delete(mock_method)
      if include?(mock_method)
        mock_method.mock_restore(watch: false)
        @mocks.delete(mock_method.to_s)
      end

      self
    end

    ##
    # Checks if the mock store includes the given mock method.
    #
    # @example
    #   mock_store = Grift::MockStore.new
    #   mock_method = Grift.mock(MyClass, :my_method)
    #   mock_store.include?(mock_method)
    #   #=> false
    #   mock_store.store(mock_method)
    #   mock_store.include?(mock_method)
    #   #=> true
    #
    # @param mock_method [Grift::MockMethod, String] the mock to search for or its hash key
    #
    # @return [Boolean] if the mock store includes that mock method
    #
    def include?(mock_method)
      @mocks.include?(mock_method.to_s)
    end

    ##
    # Checks if the mock store is empty.
    #
    # @example
    #   mock_store = Grift::MockStore.new
    #   mock_store.empty?
    #   #=> true
    #   mock_method = Grift.mock(MyClass, :my_method)
    #   mock_store.store(mock_method)
    #   mock_store.empty?
    #   #=> false
    #
    # @return [Boolean] if the mock store is empty
    #
    def empty?
      @mocks.empty?
    end

    private

    ##
    # Searches for the mock in the store. Optional filtering by class/method.
    #
    # @param klass [Class] the class to filter by, if nil all classes are included
    # @param method [Symbol] the method to filter by, if nil all symbols are included
    #
    # @return [Hash] the key, mock pairs in the store that match the criteria
    #
    def search(klass: nil, method: nil)
      return @mocks unless klass || method

      pattern = Regexp.new(Grift::MockMethod.hash_key(klass, method))
      @mocks.select { |k| pattern.match?(k) }
    end
  end
end
