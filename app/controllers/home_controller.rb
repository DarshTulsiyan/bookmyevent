class HomeController < ApplicationController
  before_action :logged_in_only, only: :account

  def index
  end

  def account
  end
end
