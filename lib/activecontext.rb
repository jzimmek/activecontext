require "activecontext/container"

module ActiveContext
  def biject(*args)
    inject(*args)
    outject(*args)
  end
  
  def inject(*names)
    names.each do |name|
      if name.is_a?(Hash)
        name.each_pair {|key, val| create_inject_method(name, val)}
      else
        create_inject_method(name, name)
      end
    end
  end
  
  def outject(*names)
    names.each do |name|
      if name.is_a?(Hash)
        name.each_pair {|key, val| create_outject_method(name, val)}
      else
        create_outject_method(name, name)
      end
    end
  end

  private

  def create_outject_method(name, as)
    raise "invalid outject name #{as}" if methods.include?(:"#{as}=")
    define_method "#{as}=" do |*args|
      Container.current[name] = args.first
    end
  end
  
  def create_inject_method(name, as)
    raise "invalid inject name #{as}" if methods.include?(as)
    define_method as do
      (value = Container.current[name]) && value.is_a?(Proc) ? value.call : value
    end
  end

end