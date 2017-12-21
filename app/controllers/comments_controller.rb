class CommentsController < ApplicationController
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

    def isa_comrade
      @post = Post.find(params[:post_id])

      post_author = User.find(@post.user_id)

      redirect_to root_url, alert: 'You must be friends to comment.' \
        unless post_author == current_user || post_author.comrades.include?(current_user)
    end
end
