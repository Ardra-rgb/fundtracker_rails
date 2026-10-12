
class InstallmentsController < ApplicationController
  before_action :set_installment, only: %i[update destroy]

  def update
    if @installment.update(installment_params)
      redirect_to dashboard_path(
        month: @installment.month.strftime("%Y-%m")
      ), notice: "Installment updated."
    else
      redirect_to dashboard_path,
                  alert: @installment.errors.full_messages.to_sentence
    end
  end

  def destroy
    month = @installment.month

    Installment.transaction do
      @installment.payment&.destroy!
      @installment.destroy!
    end

    redirect_to dashboard_path(month: month.strftime("%Y-%m")),
                notice: "Installment and associated payment deleted."
  end

  private

  def set_installment
    @installment = Installment
      .joins(:member)
      .where(members: { owner_id: Current.user.id })
      .find(params[:id])
  end

  def installment_params
    params.require(:installment).permit(
      :month,
      :due_date,
      :amount
    )
  end
end
