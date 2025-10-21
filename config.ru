# config.ru
require_relative "app/middlewares/gzip_middleware"
require_relative "app/middlewares/auth_middleware"
require_relative "config/routes"

app = Router.build  # definido en config/routes.rb
use GzipMiddleware
use AuthMiddleware
run app
