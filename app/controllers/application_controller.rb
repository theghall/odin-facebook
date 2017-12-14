class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

    def logged_in_user
      unless user_signed_in?
        flash[:alert] = 'Please login or signup'
        redirect_to root_url
      end
    end
end
