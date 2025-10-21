# app/services/async_service.rb
require_relative "../models/product"

class AsyncService
  def initialize
    @queue = Queue.new
    start_worker
  end

  def enqueue_create(name)
    @queue << name
  end

  def start_worker
    Thread.new do
      loop do
        name = @queue.pop
        sleep 5 # requisito: disponible luego de 5 segundos
        ProductStore.add(name)
      end
    end
  end
end

$async_service = AsyncService.new
