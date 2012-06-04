require "activecontext/container"

module ActiveContext
  def biject(*args)
    inject(*args)
    outject(*args)
  end
  
  def inject(*names)
    names.each do |name|
      raise "invalid inject name #{name}" if methods.include?(name)
      define_method name do
        (value = Container.current[name]) && value.is_a?(Proc) ? value.call : value
      end
    end
  end
  
  def outject(*names)
    names.each do |name|
      raise "invalid outject name #{name}" if methods.include?(:"#{name}=")
      define_method "#{name}=" do |*args|
        Container.current[name] = args.first
      end
    end
  end
end