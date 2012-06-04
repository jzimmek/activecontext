module ActiveContext
  class Container
    def initialize
      @names = {}
    end

    def register(name, ctx={}, &block)
      raise "invalid context name" if methods.include?(name)
      instance_variable_set("@#{name}", ctx)

      eigen = class << self; self; end
      eigen.send(:define_method, name) do |*args, &block2|
        raise "#{name} #{args.first} already exist" if @names.key?(args.first)
        @names[args.first] = name
        
        if args.length > 1
          raise "pass either a block or value. not both." if block2
          self[args.first] = args[1]
        end
        
        self[args.first] = block2 if block2
      end
    end

    def []=(key, value)
      if @names.key?(key)
        self.context(@names[key])[key] = value
      else
        raise "unknown name #{key}"
      end
    end

    def [](key)
      if @names.key?(key)
        self.context(@names[key])[key]
      else
        raise "unknown name #{key}"
      end
    end

    def run(&block)
      c = Thread.current[:contextualize]
      raise "found existing container" if c && c != self

      begin
        Thread.current[:contextualize] = self
        block.call
      ensure
        Thread.current[:contextualize] = nil
      end unless c
    end

    def self.current
      Thread.current[:contextualize]
    end

    def context(name)
      instance_variable_get("@#{name}")
    end

  end
end