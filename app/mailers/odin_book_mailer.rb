class OdinBookMailer < ApplicationMailer
  default from: 'notifications@odinbook.com'

  def welcome(user)
    @user = user

    mail(to: @user.email, subject: 'Welcome to OdinBook!')
  end
end
