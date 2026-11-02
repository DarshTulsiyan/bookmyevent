class HomeController < ApplicationController
  before_action :logged_in_only, only: :account

  def index
  end

  def account
    @organized_events = current_user.organized_events.order(starts_at: :asc) if current_user.organizer?
  end
end
