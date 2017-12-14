class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ApplicationHelper

  def all
    user = User.from_omniauth(request.env['omniauth.auth'])

    if user.persisted?
      send_welcome(user) unless user.welcome_sent

      sign_in_and_redirect user
    else
      redirect_to new_user_registration_url
    end
  end

  alias_method :facebook, :all

end
