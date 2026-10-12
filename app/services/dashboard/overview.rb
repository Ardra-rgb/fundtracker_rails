
module Dashboard
  class Overview
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      month = selected_month

      focused_member = if @params[:member].present?
        @user.members.find_by(id: @params[:member])
      end

      installments_scope = Installment
        .joins(:member)
        .where(
          members: { owner_id: @user.id },
          month: month
        )

      if focused_member
        installments_scope =
          installments_scope.where(member_id: focused_member.id)
      end

      installments = installments_scope
        .includes(:member, :payment)
        .order("members.member_id")
        .to_a

      payments = Payment
        .joins(installment: :member)
        .where(members: { owner_id: @user.id })
        .includes(installment: :member)
        .order(payment_date: :desc, created_at: :desc)

      payment_date_filter = @params[:payment_date].to_s.strip
      member_name_filter = @params[:member_name].to_s.strip

      if payment_date_filter.present?
        begin
          payments = payments.where(
            payment_date: Date.iso8601(payment_date_filter)
          )
        rescue Date::Error
          payments = payments.none
        end
      end

      if member_name_filter.present?
        payments = payments.where(
          "LOWER(members.name) LIKE ?",
          "%#{member_name_filter.downcase}%"
        )
      end

      selected_month_payments =
        payments.where(installments: { month: month })

      if focused_member
        selected_month_payments =
          selected_month_payments.where(
            installments: { member_id: focused_member.id }
          )
      end

      active_members = @user.members.where(active: true)
      active_member_count = active_members.count

      paid_count = Payment
        .joins(installment: :member)
        .where(
          members: {
            owner_id: @user.id,
            active: true
          },
          installments: { month: month }
        )
        .distinct
        .count("members.id")

      pending_installments = installments.select do |installment|
        installment.payment.nil?
      end

      {
        selected_month: month,
        current_month: month.strftime("%B %Y"),
        focused_member: focused_member,
        members: @user.members.order(:member_id),
        installments: installments,
        pending_installments: pending_installments,
        payments: payments,
        selected_month_payments: selected_month_payments,
        payment_date_filter: payment_date_filter,
        member_name_filter: member_name_filter,
        show_members_only: @params[:view] == "members",
        show_payments_only: @params[:view] == "payments",
        show_month_history: @params.key?(:month),
        active_members: active_member_count,
        paid_count: paid_count,
        pending_member_count: [
          active_member_count - paid_count, 0
        ].max,
        pending_count: pending_installments.length,
        current_installment_count: installments.length,
        collected: installments.sum do |installment|
          installment.payment&.amount || 0
        end
      }
    end

    private

    def selected_month
      if @params[:month].present?
        Date.strptime("#{@params[:month]}-01", "%Y-%m-%d")
      else
        Date.current.beginning_of_month
      end
    rescue Date::Error, ArgumentError
      Date.current.beginning_of_month
    end
  end
end
