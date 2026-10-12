
class CollectionPeriod < ApplicationRecord
  belongs_to :owner,
             class_name: "User",
             inverse_of: :collection_periods

  validates :start_month, :end_month, presence: true

  validates :start_month,
            uniqueness: {
              scope: [:owner_id, :end_month]
            }

  validate :end_month_cannot_be_before_start_month

  private

  def end_month_cannot_be_before_start_month
    return if start_month.blank? || end_month.blank?
    return unless end_month < start_month

    errors.add(:end_month, "cannot be before the start month")
  end
end
