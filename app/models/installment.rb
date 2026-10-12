
class Installment < ApplicationRecord
  belongs_to :member

  has_one :payment, dependent: :destroy

  validates :month, presence: true,
                    uniqueness: { scope: :member_id }

  validates :due_date, presence: true

  validates :amount,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
end
