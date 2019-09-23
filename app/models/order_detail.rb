class OrderDetail < ApplicationRecord
    belongs_to :order, class_name: "Order", foreign_key: "orders_id"
    enum order_type: [ :pure, :ordinary, :advanced ]
end
