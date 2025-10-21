require "rack"
require_relative "../app/controllers/auth_controller"
require_relative "../app/controllers/products_controller"

class StaticFileWithHeaders
  def initialize(file_path, headers = {})
    @file_path = file_path
    @headers = headers
  end

  def call(env)
    if File.exist?(@file_path)
      content = File.read(@file_path)
      [200, { 'Content-Type' => 'text/plain' }.merge(@headers), [content]]
    else
      [404, { 'Content-Type' => 'application/json' }, [{ error: 'Not Found' }.to_json]]
    end
  end
end

class Router
  def self.build
    Rack::Builder.new do
      map "/auth" do
        run AuthController.new
      end

      map "/products" do
        run ProductsController.new
      end

      # archivos estáticos
      map "/openapi.yaml" do
        run StaticFileWithHeaders.new("public/openapi.yaml", { "Cache-Control" => "no-cache" })
      end

      map "/AUTHORS" do
        run StaticFileWithHeaders.new("public/AUTHORS", { "Cache-Control" => "max-age=86400" })
      end
    end.to_app
  end
end
