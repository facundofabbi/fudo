# app/middlewares/auth_middleware.rb
require "jwt"

class AuthMiddleware
  PUBLIC_PATHS = ["/auth", "/openapi.yaml", "/AUTHORS", "/favicon.ico"]

  def initialize(app)
    @app = app
  end

  def call(env)
    path = env["PATH_INFO"]
    return @app.call(env) if PUBLIC_PATHS.include?(path) || env["REQUEST_METHOD"] == "OPTIONS"

    auth = env["HTTP_AUTHORIZATION"]
    unless auth && valid_token?(auth)
      return [401, { "Content-Type" => "application/json" }, [{ error: "Unauthorized" }.to_json]]
    end

    @app.call(env)
  end

  def valid_token?(header)
    token = header&.split(" ")&.last
    return false unless token
    begin
      payload, _ = JWT.decode(token, "secret_key", true, { algorithm: "HS256" })
      true
    rescue
      false
    end
  end
end
