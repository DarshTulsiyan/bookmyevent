module Admin
  class AccessRequestsController < ApplicationController
    before_action :admin_only
    before_action :designated_reviewer_only
    before_action :set_admin_access_request, only: %i[show approve reject]

    def index
      @pending_requests = AdminAccessRequest.pending.order(created_at: :asc)
      @reviewed_requests = AdminAccessRequest.where.not(status: :pending).order(reviewed_at: :desc)
    end

    def show
    end

    def approve
      user = @admin_access_request.approve_by!(
        reviewer: current_user,
        reviewer_note: params[:reviewer_note]
      )
      redirect_to admin_access_requests_path,
                  notice: "#{user.email} now has admin access.",
                  status: :see_other
    rescue ActiveRecord::RecordInvalid => error
      redirect_to admin_access_request_path(@admin_access_request),
                  alert: error.record.errors.full_messages.to_sentence,
                  status: :see_other
    end

    def reject
      @admin_access_request.reject_by!(
        reviewer: current_user,
        reviewer_note: params[:reviewer_note]
      )
      redirect_to admin_access_requests_path,
                  notice: "The admin access request was rejected.",
                  status: :see_other
    rescue ActiveRecord::RecordInvalid => error
      redirect_to admin_access_request_path(@admin_access_request),
                  alert: error.record.errors.full_messages.to_sentence,
                  status: :see_other
    end

    private

    def designated_reviewer_only
      return if current_user.can_review_admin_access_requests?

      redirect_to root_path, alert: "Not authorized", status: :see_other
    end

    def set_admin_access_request
      @admin_access_request = AdminAccessRequest.find(params[:id])
    end
  end
end
