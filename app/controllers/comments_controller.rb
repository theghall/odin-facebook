class CommentsController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user, only: [:create]
  before_action :isa_comrade, only: [:create]

  def create
    comment = @post.comments.build(user_id: current_user.id,  content: comment_params[:content])

    comment.save

    redirect_to root_url
  end

  private

    def comment_params
     params.require(:comment).permit(:content)
    end
end
