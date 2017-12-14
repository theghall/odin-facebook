class ConfirmationsController < Devise::ConfirmationsController
  include ApplicationHelper

  def new
    super
  end

  def show
    super

    if @user.persisted?
      send_welcome(@user) unless @user.welcome_sent
    end
  end

  def create
    super
  end
end
