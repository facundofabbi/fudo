# app/middlewares/gzip_middleware.rb
require "stringio"
require "zlib"

class GzipMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    accept = env["HTTP_ACCEPT_ENCODING"].to_s

    if accept.include?("gzip") && should_compress?(headers)
      puts "[GZIP] Se comprime la respuesta."
      compressed = gzip(body.each.map(&:to_s).join)
      headers["Content-Encoding"] = "gzip"
      headers["Content-Length"] = compressed.bytesize.to_s
      [status, headers, [compressed]]
    else
      puts "[GZIP] No se comprime la respuesta."
      [status, headers, body]
    end
  end

  def gzip(string)
    sio = StringIO.new
    gz = Zlib::GzipWriter.new(sio)
    gz.write(string)
    gz.close
    sio.string
  end

  def should_compress?(headers)
    puts "[GZIP] Content-Type recibido: #{headers['Content-Type']}"
    headers["Content-Type"] && headers["Content-Type"].include?("application/json")
  end
end
