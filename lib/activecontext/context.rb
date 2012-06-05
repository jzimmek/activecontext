module ActiveContext
  class Context
    attr_accessor :serialize, :deserialize
    def initialize(storage)
      @storage = storage
      @values = {}
      @serialize = ->(key, value){ value }
      @deserialize = ->(key, value){ value }
    end
    def [](key)
      if @values.key?(key)
        @values[key]
      else
        @values[key] = @deserialize.call(key, @storage[key])
      end
    end
    def []=(key, value)
      @storage[key] = @serialize.call(key, value)
      @values[key] = value
    end
  end
end