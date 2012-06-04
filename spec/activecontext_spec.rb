require "rspec"
require "activecontext"

describe ActiveContext do
  
  class TestObject
  end
  
  def new_test_object
    t = TestObject.new
    
    def t.eigenclass
      class << self; self; end
    end
    
    t
  end
  
  describe "inject" do
    it "should create a method for the injected name" do
      o = new_test_object
      o.eigenclass.instance_eval do
        extend ActiveContext
        inject :somename
      end
      o.should respond_to(:somename)
    end
    
    it "should create multiple methods when passing multiple injected names" do
      o = new_test_object
      o.eigenclass.instance_eval do
        extend ActiveContext
        inject :somename, :othername
      end
      o.should respond_to(:somename)
      o.should respond_to(:othername)
    end
  
    it "should fail if a method with the same name as injected already exist" do
      o = new_test_object
      lambda do
        o.eigenclass.instance_eval do
          extend ActiveContext
            inject :to_s
        end
      end.should raise_error("invalid inject name to_s")
    end
    
    it "should return the value of the injected name" do
      c = ActiveContext::Container.new
      c.register :request, {}
      c.request :somename, :joe
      
      c.run do
        o = new_test_object
        o.eigenclass.instance_eval do
          extend ActiveContext
          inject :somename
        end
      
        o.somename.should be(:joe)
      end
    end
  
    it "should return the value of the injected name" do
      c = ActiveContext::Container.new
      c.register :request, {}
      c.request :somename do
        :joe
      end
      
      c.run do
        o = new_test_object
        o.eigenclass.instance_eval do
          extend ActiveContext
          inject :somename
        end
      
        o.somename.should be(:joe)
      end
    end
    
    it "should return nil if no value exist" do
      c = ActiveContext::Container.new
      c.register :request, {}
      c.request :somename
      
      c.run do
        o = new_test_object
        o.eigenclass.instance_eval do
          extend ActiveContext
          inject :somename
        end
      
        o.somename.should be_nil
      end
    end
    
  end
  
  describe "outject" do
    it "should create a method for the injected name" do
      o = new_test_object
      o.eigenclass.instance_eval do
        extend ActiveContext
        outject :somename
      end
      o.should respond_to(:"somename=")
    end
  
    it "should create multiple methods when passing multiple outjected names" do
      o = new_test_object
      o.eigenclass.instance_eval do
        extend ActiveContext
        outject :somename, :othername
      end
      o.should respond_to(:"somename=")
      o.should respond_to(:"othername=")
    end
  
    it "should fail if a method with the same name as outjected already exist" do
      o = new_test_object
      lambda do
        o.eigenclass.instance_eval do
          extend ActiveContext
          def dummy=(key, value)
          end
          outject :dummy
        end
      end.should raise_error("invalid outject name dummy")
    end
    
    it "should set the outjected value and read it back" do
      c = ActiveContext::Container.new
      ctx = {}
      c.register :request, ctx
      c.request :somename, :joe
      
      c.run do
        o = new_test_object
        o.eigenclass.instance_eval do
          extend ActiveContext
          inject :somename
          outject :somename
        end
  
        o.somename = :bob
        o.somename.should be(:bob)
      end
      
      ctx.should eql({:somename => :bob})
    end
  end
  
  describe "biject" do
    it "should create a method pair for injected and outjected of the passed name" do
      o = new_test_object
      o.eigenclass.instance_eval do
        extend ActiveContext
        biject :somename
      end
      o.should respond_to(:somename)
      o.should respond_to(:"somename=")
    end
    
    it "should create multiple method pairs for injected an outjected of the passed names" do
      o = new_test_object
      o.eigenclass.instance_eval do
        extend ActiveContext
        biject :somename, :othername
      end
      o.should respond_to(:somename)
      o.should respond_to(:"somename=")
      o.should respond_to(:othername)
      o.should respond_to(:"othername=")
    end
  end
end
