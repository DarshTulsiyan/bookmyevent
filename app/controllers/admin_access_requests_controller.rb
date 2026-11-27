class AdminAccessRequestsController < ApplicationController
  def new
    @admin_access_request = AdminAccessRequest.new
  end

  def create
    @admin_access_request = AdminAccessRequest.new(admin_access_request_params)

    if @admin_access_request.save
      redirect_to login_path,
                  notice: "Your request was submitted. You can use your email and chosen password after approval.",
                  status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def admin_access_request_params
    params.require(:admin_access_request).permit(
      :name,
      :email,
      :reason,
      :password,
      :password_confirmation
    )
  end
end
