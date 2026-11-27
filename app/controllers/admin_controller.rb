class AdminController < ApplicationController
  before_action :admin_only

  def dashboard
    @user_count = User.count
    @event_count = Event.count
    @pending_event_count = Event.pending.count
    @published_event_count = Event.approved.count
    @rejected_event_count = Event.rejected.count
    @pending_admin_access_request_count =
      if current_user.can_review_admin_access_requests?
        AdminAccessRequest.pending.count
      else
        0
      end
    @user_role_counts = User.roles.keys.index_with { |role| User.where(role: role).count }
    @users = User.order(:name, :email)
  end

  def users
    @users = User.order(:name, :email)
  end

  def pending_events
    @events = Event.pending.includes(:organizer).with_attached_authorization_document.order(:created_at)
  end

  def published_events
    @events = Event.approved.includes(:organizer).with_attached_authorization_document.order(:starts_at)
  end

  def rejected_events
    @events = Event.rejected.includes(:organizer).with_attached_authorization_document.order(created_at: :desc)
  end
end
