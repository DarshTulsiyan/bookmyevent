class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    # Role is read on its own and checked against an allowlist,
    # so it is never mass-assigned.
    selected_role = params.dig(:user, :role).to_s

    @user = User.new(user_params)

    unless %w[attendee organizer].include?(selected_role)
      @user.errors.add(:role, "must be attendee or organizer")
      render :new, status: :unprocessable_entity
      return
    end

    @user.role = selected_role

    if @user.save
      reset_session
      session[:user_id] = @user.id

      redirect_to root_path,
                  notice: "Account created successfully",
                  status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
