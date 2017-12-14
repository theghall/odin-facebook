class PostsController < ApplicationController
  before_action :logged_in_user, only: [:create]

  def create
    post = current_user.posts.build(post_params)

    if post.save
      redirect_to root_url
    else
      flash[:alert] = 'Cannot post a blank status'
      redirect_to root_url
    end
  end

  private

    def post_params
      params.require(:post).permit(:content)
    end
end
