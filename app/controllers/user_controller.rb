class UserController < ApplicationController
  include ComradesHelper

  before_action :logged_in_user, only: [:index, :show]

  def show
    @user = User.find(params[:id])

    @request = Comrade.from_profile(current_user.id, params[:id])

    @common_comrades = current_user.common_comrades_with(@user)
  end

  def index
    @users = User.all_but(current_user)
  end
end
