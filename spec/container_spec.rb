require "rspec"
require "activecontext/container"

describe ActiveContext::Container do
  
  it "should not contain any known names" do
    ActiveContext::Container.new.instance_variable_get("@names").should be_empty
  end
  
  it "should fail if an unknown name is accessed" do
    c = ActiveContext::Container.new
    lambda do
      c[:key]
    end.should raise_error("unknown name key")
  end

  it "should fail when setting an unknown name" do
    c = ActiveContext::Container.new
    lambda do
      c[:key] = 1
    end.should raise_error("unknown name key")
  end
  
  it "should set current container, run block and clean up container" do
    c = ActiveContext::Container.new
    c.run do
      ActiveContext::Container.current.should be(c)
    end
    ActiveContext::Container.current.should be_nil
  end
  
  it "should support nesting of the same container" do
    c = ActiveContext::Container.new
    c.run do
      c.run do
        ActiveContext::Container.current.should be(c)
      end
      ActiveContext::Container.current.should be(c)
    end
    ActiveContext::Container.current.should be_nil
  end
  
  it "should fail when different container exist" do
    c = ActiveContext::Container.new
    c.run do
      c2 = ActiveContext::Container.new
      lambda do
        c2.run
      end.should raise_error("found existing container")
    end
  end
  
  describe "registering a context" do
    it "should create an instance variable with same name as context" do
      c = ActiveContext::Container.new
      ctx = {}
      c.register :request, ctx
      c.context("request").should eq(ctx)
    end
    
    it "should create a method with same name as context to declare names in this context" do
      c = ActiveContext::Container.new
      c.register :request, {}
      c.methods(:request).should_not be_nil
    end
    
    it "should fail when a method with same name already exist" do
      c = ActiveContext::Container.new
      lambda do
        c.register :register, {}
      end.should raise_error("invalid context name")
    end
    
    describe "registering a name" do
      it "should map the name to a context" do
        c = ActiveContext::Container.new
        c.register :request, {}
        c.request :somename
        c.instance_variable_get("@names").should eq({:somename => :request})
      end
      
      it "should fail if name already exist" do
        c = ActiveContext::Container.new
        c.register :request, {}
        c.request :somename
        lambda do
          c.request :somename
        end.should raise_error("request somename already exist")
      end
      
      it "should take a initial value as second argument" do
        c = ActiveContext::Container.new
        c.register :request, {}
        c.request :somename, :joe
        c.context("request")[:somename].should be(:joe)
      end

      it "should take a initial value factory as block" do
        c = ActiveContext::Container.new
        c.register :request, {}
        factory = -> { :joe }
        c.request :somename, &factory
        c.context("request")[:somename].should be(factory)
      end
      
      it "should fail when passing a initial value argument and a block at the same time" do
        c = ActiveContext::Container.new
        c.register :request, {}
        factory = -> { :joe }
        lambda do
          c.request :somename, :bob, &factory
        end.should raise_error("pass either a block or value. not both.")
      end
    end
    
    it "should set a value" do
      c = ActiveContext::Container.new
      c.register :request, {}
      c.request :somename
      c[:somename] = :joe
      c[:somename].should be(:joe)
    end
    
    it "should get the initial value" do
      c = ActiveContext::Container.new
      c.register :request, {}
      c.request :somename, :joe
      c.request :othername do
        :bob
      end
      c[:somename].should be(:joe)
      c[:othername].call.should be(:bob)
    end
  end
  
end