class StaticPagesController < ApplicationController

  def home
    if user_signed_in?
     @post = Post.new

     @user = current_user

     @posts = @user.posts
    end
  end
end
