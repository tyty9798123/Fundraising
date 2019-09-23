class AddPaytimeInOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :pay_time, :string
  end
end
