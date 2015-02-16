class Order < ActiveRecord::Base
  ORDER_NO_COUNT = 11

  belongs_to :customer
  has_many :order_lines

  after_create :generate_no

  def generate_no
    str = self.id.to_s
    zero_count = ORDER_NO_COUNT - str.size
    self.order_no = "O" + "0" * zero_count + str
    self.save
  end

  def self.create_order(current_user, products)
    prices = Product.select(:id, :price).where(id: products.values.map{|e| e["id"].to_i})
    prices = Hash[prices.map{|row| [row.id.to_s, row.price]}]

    order = current_user.orders.create(
      {
        total: products.map{|k, v| prices[v["id"]] * v["qty"].to_i}.inject(:+),
        date: Time.now.strftime("%Y-%m-%d"),
        status: 'process'
      }
    )
    order.order_lines = products.map do |k, v|
      OrderLine.create(
        {
          product_id: v["id"],
          qty: v["qty"].to_i,
          unit_price: v["price"].to_f,
          total_price: v["price"].to_f * v["qty"].to_i
        }
      )
    end

    order.save
  end

end