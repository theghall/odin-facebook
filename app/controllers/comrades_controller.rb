class ComradesController < ApplicationController
  before_action :logged_in_user

  def index
    @comrade_requests = current_user.requests
  end

  def create
    requestee = User.find(comrade_params[:requestee])

    requestee.pending_comrades << current_user

    redirect_to profile_path(requestee)
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

    requestee_id = request.requestee_id

    request.delete

    redirect_to profile_path(requestee_id)
  end

  private

    def comrade_params
      params.require(:comrade).permit(:requestee)
    end
end
