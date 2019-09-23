class Order < ApplicationRecord
    belongs_to :user, class_name: "User", foreign_key: "users_id"
    belongs_to :product, class_name: "Project", foreign_key: "projects_id"
    has_many :order_details
    enum is_payment: [ :not_pay_yet, :is_pay ]
end
