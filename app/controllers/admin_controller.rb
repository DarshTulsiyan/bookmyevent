class AdminController < ApplicationController
  before_action :admin_only

  def dashboard
    @user_count = User.count
    @event_count = Event.count
    @pending_event_count = Event.pending.count
    @published_event_count = Event.approved.count
    @user_role_counts = User.roles.keys.index_with { |role| User.where(role: role).count }
    @users = User.order(:name, :email)
  end

  def users
    @users = User.order(:name, :email)
  end

  def pending_events
    @events = Event.pending.includes(:organizer).order(:created_at)
  end

  def published_events
    @events = Event.approved.includes(:organizer).order(:starts_at)
  end
end
