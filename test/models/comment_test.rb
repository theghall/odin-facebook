require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    @jack = users(:jack)
    @jack_post = posts(:jack_post)
    @jack_post_comment = @jack_post.comments.build(user_id: @jack.id, content: 'comment')
  end

  test "should be valid" do
    assert @jack_post_comment.valid?
  end

  test "should be invalid with empty post_id" do
    comment = Comment.new(user_id: @jack.id, content: 'comment')
    assert_not comment.valid?
  end

  test "should be invalid with empty user_id" do
    comment = Comment.new(post_id: @jack_post.id, content: 'comment')
    assert_not comment.valid?
  end

  test "should be invalid with empty comment" do
    @jack_post_comment.content = " "
    assert_not @jack_post_comment.valid?
  end

  test "should allow a user to post multiple comments" do
    @jack_post_comment.save!
    assert_equal 0, @jack_post_comment.errors.count do
      @jack_post_comment.save!
    end
  end

  test "should return user record" do
    @jack_post_comment.save
    assert @jack_post_comment.respond_to?(:user)
    assert_equal @jack, @jack_post_comment.user
  end

  test "should return post record" do
    @jack_post_comment.save
    assert @jack_post_comment.respond_to?(:user)
    assert_equal @jack_post, @jack_post_comment.post
  end
end
