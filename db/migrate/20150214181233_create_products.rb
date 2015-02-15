class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 4
      t.boolean :status
      t.string :description
      t.timestamps
    end
  end
end
