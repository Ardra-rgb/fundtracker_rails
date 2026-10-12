
class MembersController < ApplicationController
  before_action :set_member, only: %i[update destroy]

  def create
    month = selected_month
    @member = Current.user.members.new(member_params)

    Member.transaction do
      @member.save!

      @member.installments.find_or_create_by!(month: month) do |installment|
        installment.due_date = month.end_of_month
        installment.amount = @member.monthly_amount
      end
    end

    redirect_to dashboard_path(month: month.strftime("%Y-%m")),
                notice: "Member added."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to dashboard_path,
                alert: error.record.errors.full_messages.to_sentence
  end

  def update
    if @member.update(member_params)
      redirect_to dashboard_path, notice: "Member updated."
    else
      redirect_to dashboard_path,
                  alert: @member.errors.full_messages.to_sentence
    end
  end

  def destroy
    @member.destroy!

    redirect_to dashboard_path,
                notice: "Member and associated records deleted."
  end

  private

  def set_member
    @member = Current.user.members.find(params[:id])
  end

  def member_params
    params.require(:member).permit(
      :member_id,
      :name,
      :phone,
      :monthly_amount,
      :active
    )
  end

  def selected_month
    if params[:month].present?
      Date.strptime("#{params[:month]}-01", "%Y-%m-%d")
    else
      Date.current.beginning_of_month
    end
  rescue Date::Error, ArgumentError
    Date.current.beginning_of_month
  end
end
