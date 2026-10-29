class SessionsController < ApplicationController
  before_action :logged_in_only, only: :destroy

  rate_limit to: 10,
             within: 3.minutes,
             only: :create,
             with: -> {
               redirect_to login_path,
                           alert: "Too many attempts. Try again later.",
                           status: :see_other
             }

  def new
  end

  def create
    user = User.authenticate_by(
      email: params[:email].to_s.strip.downcase,
      password: params[:password].to_s
    )

    if user && !user.suspended?
      reset_session
      session[:user_id] = user.id

      redirect_to root_path,
                  notice: "Logged in successfully",
                  status: :see_other
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session

    redirect_to root_path,
                notice: "Logged out successfully",
                status: :see_other
  end
end
