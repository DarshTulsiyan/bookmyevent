class HomeController < ApplicationController
  before_action :logged_in_only, only: :account

  def index
  end

  def account
    if current_user.can_access_role_view?(:organizer)
      @organized_events = current_user.organized_events.order(starts_at: :asc)
    end
  end
end
