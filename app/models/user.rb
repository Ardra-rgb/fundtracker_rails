
class User < ApplicationRecord
  has_secure_password

  has_many :members,
           foreign_key: :owner_id,
           dependent: :destroy,
           inverse_of: :owner

  has_many :collection_periods,
           foreign_key: :owner_id,
           dependent: :destroy,
           inverse_of: :owner

  has_many :recorded_payments,
           class_name: "Payment",
           foreign_key: :recorded_by_id,
           dependent: :nullify

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 150 }
end
