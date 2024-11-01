module Authenticator
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      puts request.session[:user_session_id]
      if request.session[:user_session_id].nil?
        return  [ 401, { "Content-Type" => "application/json" }, [ { message: "unauthorized" }.to_json ] ]
      end

      user = User.find_by(id: request.session[:user_session_id])
      if user.nil?
        return  [ 401, { "Content-Type" => "application/json" }, [ { message: "unauthorized" }.to_json ] ]
      end

      request.env["user"] = user
      @app.call(env)
    end
  end
end
