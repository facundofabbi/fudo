# app/utils/response_helper.rb
require 'json'

class ResponseHelper
  def self.json(obj, status = 200)
    [status, { 'Content-Type' => 'application/json' }, [JSON.generate(obj)]]
  end

  def self.error(message, status = 400)
    json({ error: message }, status)
  end
end
