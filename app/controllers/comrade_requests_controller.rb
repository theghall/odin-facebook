class ComradeRequestsController < ApplicationController
  include ComradeRequestsHelper

  before_action :logged_in_user, only: [:index, :create, :show, :update, :destroy]

  def index
    @comrade_requests = current_user.requests
  end

  def update
    request = Comrade.find(params[:id])

    if !request.update(accepted: true)
      flash[:alert] = 'Comrade request was not able to be accepted.' 
    end

    redirect_to comrades_path
  end

  def create
    requestee = User.find(comrade_request_params[:requestee])

    Comrade.with_advisory_lock('comrade_request') do
      begin
        requestee.pending_comrades << current_user
      rescue ActiveRecord::RecordInvalid
        flash[:alert] = 'That user sent you a request'
      end
    end

    redirect_to profile_path(requestee)
  end

  def show
    @request = Comrade.find(params[:id])
  end

  def destroy
    requestee_id = destroy_request(params[:id])

    redirect_to profile_path(requestee_id)
  end

  private

    def comrade_request_params
      params.require(:comrade).permit(:requestee)
    end
end
