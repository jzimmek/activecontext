require "activecontext/container"
require "rack/request"

module ActiveContext
  class Rack
    def initialize(app, &block)
      @app = app
      @block = block
    end

    def call(env)
      req = ::Rack::Request.new(env)

      container = Container.new

      container.register :request, {}
      container.register :session, req.session

      container.instance_exec(req, &@block) if @block

      container.run do
        @app.call(env)
      end
    end
  end
end
