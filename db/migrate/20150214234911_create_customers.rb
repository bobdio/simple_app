class CreateCustomers < ActiveRecord::Migration
  create_table :customers do |t|
    t.string :firstname
    t.string :lastname
    t.string :email
    t.string :password_digest

    t.timestamps
  end
end
