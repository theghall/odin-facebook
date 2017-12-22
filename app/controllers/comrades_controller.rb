class ComradesController < ApplicationController
  include ComradeRequestsHelper

  before_action :logged_in_user

  def index
    @comrades = current_user.comrades
  end

  def destroy
    destroy_request(params[:id])

    redirect_back(fallback_location: comrades_path)
  end

  private

    def comrade_params
      params.require(:comrade).permit(:requestee)
    end
end
