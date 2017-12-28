class WorthiesController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user, only: [:create, :destroy]
  before_action :isa_comrade, only: [:create]

  def create
    post = Post.find(params[:post_id])

    worthy = post.worthies.build(user_id: current_user.id)

    worthy.save

    redirect_to root_url
  end

  def destroy
    worthy = Worthy.find(params[:id])

    worthy.delete

    redirect_to root_url
  end
end
