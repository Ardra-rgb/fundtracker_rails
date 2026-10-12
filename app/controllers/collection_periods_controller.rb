
class CollectionPeriodsController < ApplicationController
  def create
    @period = Current.user.collection_periods.new(period_params)

    if @period.save
      redirect_to dashboard_path(
        month: @period.start_month.strftime("%Y-%m")
      ), notice: "Collection period created."
    else
      redirect_to dashboard_path,
                  alert: @period.errors.full_messages.to_sentence
    end
  end

  def generate_installments
    @period = Current.user.collection_periods.find(params[:id])

    month = @period.start_month.beginning_of_month
    final_month = @period.end_month.beginning_of_month

    CollectionPeriod.transaction do
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
    )
  end
end
