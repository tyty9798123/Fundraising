class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.belongs_to :projects
      t.belongs_to :users
      t.integer :is_payment
      t.timestamps
    end
  end
end
