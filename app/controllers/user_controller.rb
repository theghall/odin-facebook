class UserController < ApplicationController
  before_action :logged_in_user, only: [:index, :show]

  def show
    @user = User.find(params[:id])

    @request = Comrade.from_profile(params[:id], current_user)
  end

  def index
    @users = User.all_but(current_user)
  end
end
