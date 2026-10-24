class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    attributes = user_params
    selected_role = attributes.delete(:role)

    @user = User.new(attributes)

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
      :password_confirmation,
      :role
    )
  end
end