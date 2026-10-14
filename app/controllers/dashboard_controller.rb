class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @dashboard = Dashboard::Overview.new(
      user: Current.user,
      params: params
    ).call
  end
end
