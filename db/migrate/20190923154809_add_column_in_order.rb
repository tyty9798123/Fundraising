class AddColumnInOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :order_no, :integer
  end
end
