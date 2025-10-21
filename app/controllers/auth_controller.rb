# app/controllers/auth_controller.rb
require "json"
require "jwt"

class AuthController
  def call(env)
    req = Rack::Request.new(env)
    puts "Request method: #{req.request_method}"
    puts "Request path: #{req.path}"

    if req.post?
      begin
        body = req.body.read
        puts "Raw body: #{body}"
        payload = JSON.parse(body)
        user = payload["user"]
        pass = payload["password"]
        puts "User: #{user}, Password: #{pass}"

        token = JWT.encode({ user: user, iat: Time.now.to_i }, "secret_key", "HS256")
        puts "Generated token: #{token}"

        [200, { "Content-Type" => "application/json" }, [{ token: token }.to_json]]
      rescue => e
        puts "Error parsing JSON: #{e.message}"
        [400, { "Content-Type" => "application/json" }, [{ error: "Bad request" }.to_json]]
      end
    else
      [405, { "Content-Type" => "application/json" }, [{ error: "Method not allowed" }.to_json]]
    end
  end
end
