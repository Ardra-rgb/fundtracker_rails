class LoginController < ApplicationController
  def index
    redirect_to dashboard_path if Current.user.present?
  end

  def register
  end

  def create
    username = params[:username].to_s.strip

    user = User.where(
      "LOWER(username) = ?",
      username.downcase
    ).first

    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      Current.user = user

      redirect_to dashboard_path, notice: "Login successful."
    else
      flash.now[:alert] = "Invalid username or password."
      render :index, status: :unprocessable_entity
    end
  end

  def create_account
    @user = User.new(
      username: params[:username].to_s.strip,
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if @user.save
      redirect_to login_path, notice: "Account created. Please sign in."
    else
      flash.now[:alert] =
        "Please enter a correct username and password. Passwords are case-sensitive."

      render :index, status: :unprocessable_entity
    end
  end

  def logout
  reset_session
  Current.reset

  redirect_to login_path, notice: "Logged out successfully."
end
end