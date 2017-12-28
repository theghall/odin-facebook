class RegistrationsController < Devise::RegistrationsController
  include ApplicationHelper

  def create
    super
  end

  def edit
    super
  end

  def update
    super
  end

  def destroy
    Comrade.with_advisory_lock(comrade_request) do
      super
    end
  end

  private

    def sign_up_params
      params.require(:user).permit(:email, :name, :password, :password_confirmation)
    end
    
    def account_update_params
      params.require(:user).permit(:email, :name, :password, :password_confirmation, :current_password)
    end
end
