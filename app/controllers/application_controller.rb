class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])

    if @current_user&.suspended?
      reset_session
      @current_user = nil
    end

    @current_user
  end

  def logged_in_only
    return true if current_user

    redirect_to login_path,
                alert: "Please log in",
                status: :see_other

    false
  end

  def organizer_only
    return unless logged_in_only
    return if current_user.organizer?

    redirect_to root_path,
                alert: "Not authorized",
                status: :see_other
  end

  def admin_only
    return unless logged_in_only
    return if current_user.admin?

    redirect_to root_path,
                alert: "Not authorized",
                status: :see_other
  end
end
