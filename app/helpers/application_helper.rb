module ApplicationHelper
  def app_name
    "OdinBook"
  end

  def full_title(title = '')
    title.empty? ? app_name : title + ' | ' + app_name
  end

  def send_welcome(user)
    dtime = Rails.env.production? ? 'deliver_later' : 'deliver_now'

    OdinBookMailer.welcome(user).send("#{dtime}")

    user.sent_welcome(true)

    user.save
  end
end
