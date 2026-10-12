
class Member < ApplicationRecord
  belongs_to :owner,
             class_name: "User",
             inverse_of: :members

  has_many :installments, dependent: :destroy

  validates :member_id,
            presence: true,
            length: { maximum: 20 },
            uniqueness: { scope: :owner_id }

  validates :name,
            presence: true,
            length: { maximum: 150 }

  validates :phone,
            presence: true,
            length: { maximum: 15 }

  validates :monthly_amount,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :active, inclusion: { in: [true, false] }
end
