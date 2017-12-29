class StaticPagesController < ApplicationController

  def home
    if user_signed_in?
     @post = Post.new

     @user = current_user

     @posts = User.feed(current_user)
    end
  end

  def privacy

  end

end
