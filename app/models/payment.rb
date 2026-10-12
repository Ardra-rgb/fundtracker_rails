
class Payment < ApplicationRecord
  belongs_to :installment

  belongs_to :recorded_by,
             class_name: "User",
             optional: true

  validates :amount,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :payment_date, presence: true

  validates :reference, length: { maximum: 100 }

  validates :installment_id, uniqueness: true
end
