
class MembersController < ApplicationController
  before_action :set_member, only: %i[update destroy]

  def create
    month = selected_month
    @member = Current.user.members.new(member_params)
    user = Current.user

    Member.transaction do
      user.with_lock do
        ledger_number = user.last_member_ledger_number + 1
        user.update!(last_member_ledger_number: ledger_number)

        @member.ledger_number = ledger_number
        @member.member_id = generated_member_id(user, ledger_number)
        @member.save!

        @member.installments.find_or_create_by!(month: month) do |installment|
          installment.due_date = month.end_of_month
          installment.amount = @member.monthly_amount
        end
      end
    end

    redirect_to dashboard_path(
      view: dashboard_view,
      month: month.strftime("%Y-%m")
    ),
                notice: "Member added."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to dashboard_path(
      view: dashboard_view,
      month: month.strftime("%Y-%m")
    ),
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

  def dashboard_view
    params[:view] == "members" ? "members" : "overview"
  end

  def generated_member_id(user, ledger_number)
    candidate_number = ledger_number

    loop do
      candidate = "M#{candidate_number.to_s.rjust(3, '0')}"
      return candidate unless user.members.exists?(member_id: candidate)

      candidate_number += 1
    end
  end
end
