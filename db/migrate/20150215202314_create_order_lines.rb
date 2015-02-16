class CreateOrderLines < ActiveRecord::Migration
  create_table :order_lines do |t|
    t.references :order
    t.references :product
    t.integer :qty
    t.decimal :unit_price, precision: 10, scale: 4
    t.decimal :total_price, precision: 10, scale: 4

    t.timestamps
  end
end
