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

  def isa_comrade
    @post = Post.find(params[:post_id])

    post_author = User.find(@post.user_id)

    redirect_to root_url, alert: 'You must be friends to comment.' \
      unless post_author == current_user || post_author.comrades.include?(current_user)
  end

  def comrade_request
    'comrade_request'
  end
end
