class ComradeRequestsController < ApplicationController
  include ApplicationHelper, ComradeRequestsHelper

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
    requestee = User.find_by(id: comrade_request_params[:requestee])

    flash[:alert] = 'That user no longer exists' if requestee.nil?

    Comrade.with_advisory_lock(comrade_request) do
      begin
        requestee.pending_comrades << current_user unless requestee.nil?
      rescue ActiveRecord::RecordInvalid
        flash[:alert] = 'That user sent you a request'
      end
    end

    redirect_to (requestee.nil? ? profiles_path : profile_path(requestee))
  end

  def show
    @request = Comrade.find(params[:id])
  end

  def destroy
    begin
      requestee_id = destroy_request(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The other user aleady performed that action"
    end

    redirect_to (requestee_id.nil? ? profiles_path : profile_path(requestee_id))
  end

  private

    def comrade_request_params
      params.require(:comrade).permit(:requestee)
    end
end
