# app/controllers/products_controller.rb
require 'json'
require_relative '../utils/response_helper'
require_relative '../models/product'
require_relative '../services/async_job_service'

class ProductsController
  def call(env)
    req = Rack::Request.new(env)
    case req.request_method
    when 'POST'
      body = JSON.parse(req.body.read)
      $async_service.enqueue_create(body['name'])
      ResponseHelper.json({ status: 'queued' })
    when 'GET'
      ResponseHelper.json(ProductStore.all)
    else
      ResponseHelper.error('Method not allowed', 405)
    end
  end
end
