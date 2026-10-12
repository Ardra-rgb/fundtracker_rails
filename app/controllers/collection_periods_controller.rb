class CollectionPeriodsController < ApplicationController
  before_action :authenticate_user!

  def new
    @collection_period = Current.user.collection_periods.new(
      start_month: Date.current.beginning_of_month,
      end_month: Date.current.beginning_of_month
    )
  end

  def create
    @collection_period = Current.user.collection_periods.new(period_params)

    CollectionPeriod.transaction do
      @collection_period.save!
      generate_installments_for(@collection_period)
    end

    redirect_to dashboard_path(
      month: @collection_period.start_month.strftime("%Y-%m")
    ), notice: "Collection months and installments created."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to dashboard_path,
                alert: error.record.errors.full_messages.to_sentence
  end

  def generate_installments
    @period = Current.user.collection_periods.find(params[:id])

    CollectionPeriod.transaction do
      generate_installments_for(@period)
    end

    redirect_to dashboard_path(
      month: @period.start_month.strftime("%Y-%m")
    ), notice: "Installments generated."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to dashboard_path,
                alert: error.record.errors.full_messages.to_sentence
  end

  private

  def period_params
    params.require(:collection_period).permit(
      :start_month,
      :end_month
    ).to_h.transform_values do |value|
      month = value.to_s
      if /\A\d{4}-(0[1-9]|1[0-2])\z/.match?(month)
        Date.strptime("#{month}-01", "%Y-%m-%d")
      else
        value
      end
    end
  end

  def generate_installments_for(period)
    month = period.start_month.beginning_of_month
    final_month = period.end_month.beginning_of_month

    while month <= final_month
      Current.user.members
        .where(active: true)
        .where("created_at < ?", month.next_month)
        .find_each do |member|
        member.installments.find_or_create_by!(month: month) do |installment|
          installment.due_date = month.end_of_month
          installment.amount = member.monthly_amount
        end
      end

      month = month.next_month
    end
  end
end
