
class ApplicationController < ActionController::Base
  # Only allow modern browsers
  allow_browser versions: :modern

  # Refresh page caching when import maps change
  stale_when_importmap_changes

  # Identify the user for each request
  before_action :set_current_user

  private

  def set_current_user
    Current.user = User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    return if Current.user.present?

    redirect_to login_path, alert: "Please log in to continue."
  end
end
