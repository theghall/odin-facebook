class ComradesController < ApplicationController
  before_action :logged_in_user

  def index
    @comrade_requests = current_user.passive_requests
  end

  def create
    followed = User.find(comrade_params[:followed])

    followed.pending_comrades << current_user

    redirect_to profile_path(followed)
  end

  def update
    request = Comrade.find(params[:id])

    if !request.update(accepted: true)
      flash[:alert] = 'Comrade request was not able to be accepted.' 
    end

    redirect_to comrades_path
  end

  def destroy
    request = Comrade.find(params[:id])

    followed_id = request.followed_id

    request.delete

    redirect_to profile_path(followed_id)
  end

  private

    def comrade_params
      params.require(:comrade).permit(:followed)
    end
end
