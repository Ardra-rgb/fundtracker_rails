
class PaymentsController < ApplicationController
  def create
    @installment = Installment
      .joins(:member)
      .where(members: { owner_id: Current.user.id })
      .find(params[:installment_id])

    if @installment.payment.present?
      redirect_to dashboard_path(
        month: @installment.month.strftime("%Y-%m")
      ), alert: "This installment is already paid."
      return
    end

    @payment = @installment.build_payment(
      amount: @installment.amount,
      payment_date: payment_params[:payment_date],
      reference: payment_params[:reference],
      recorded_by: Current.user
    )

    if @payment.save
      redirect_to dashboard_path(
        month: @installment.month.strftime("%Y-%m")
      ), notice: "Payment recorded."
    else
      redirect_to dashboard_path(
        month: @installment.month.strftime("%Y-%m")
      ), alert: @payment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @payment = Payment
      .joins(installment: :member)
      .where(members: { owner_id: Current.user.id })
      .find(params[:id])

    month = @payment.installment.month
    @payment.destroy!

    redirect_to dashboard_path(
      month: month.strftime("%Y-%m")
    ), notice: "Payment deleted. The installment is now unpaid."
  end

  private

  def payment_params
    params.require(:payment).permit(
      :payment_date,
      :reference
    )
  end
end
