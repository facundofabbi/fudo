# app/models/product.rb
class ProductStore
  @products = []
  @next_id = 1
  @mutex = Mutex.new

  class << self
    def add(name)
      @mutex.synchronize do
        p = { "id" => @next_id, "name" => name }
        @products << p
        @next_id += 1
        p
      end
    end

    def all
      @products.dup
    end
  end
end
