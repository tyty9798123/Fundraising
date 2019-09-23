class CreateOrderDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :order_details do |t|
      t.integer :order_type
      t.integer :quantity
      t.integer :total
      t.belongs_to :orders
      t.timestamps
    end
  end
end
