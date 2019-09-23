class AddPaymentTypeInOrderDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :order_details, :payment_type, :string
  end
end
