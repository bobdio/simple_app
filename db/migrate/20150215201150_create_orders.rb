class CreateOrders < ActiveRecord::Migration
  create_table :orders do |t|
    t.string :order_no, limit: 30
    t.references :customer
    t.decimal :total, precision: 10, scale: 4
    t.date :date
    t.string :status, limit: 10
    t.string :token, limit: 32

    t.timestamps
  end
end
