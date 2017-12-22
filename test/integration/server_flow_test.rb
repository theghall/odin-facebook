require 'test_helper'

class ServerFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @jack = users(:jack)
    @jack_post = posts(:jack_post)
    @john = users(:john)
    @jill = users(:jill)
    @jill_post = posts(:jill_post)
    @jack_and_jill = comrades(:jack_and_jill)
    @julian = users(:julian)
  end

  # Posting flow
  test "should increase posts count by 1 after posting" do
    sign_in @jack
    get root_url
    assert_difference 'Post.count', 1 do
      post posts_path, params: { post: { content: 'content' }}
    end
  end

  # Comrade request flow
  test "should have user with a pending comrade request" do
    sign_in @jack
    get root_url
    refute_includes @julian.pending_comrades, @jack
    refute_includes @julian.comrades, @jack
    assert_difference 'Comrade.count', 1 do
      post comrade_requests_path, params: { comrade: { requestee: @julian.id }}
    end
    assert_includes @julian.pending_comrades, @jack
    refute_includes @julian.comrades, @jack
  end

  test "should have user be comrades with another user" do
    sign_in @jack
    get root_url
    refute_includes @jack.comrades, @jill
    assert_includes @jill.pending_comrades, @jack
    patch comrade_request_path(@jack_and_jill)
    @jack.reload
    refute_includes @jill.pending_comrades, @jack
    assert_includes @jack.comrades, @jill
    assert_includes @jill.comrades, @jack
  end

  test "should delete pending comrade request" do
    sign_in @jack
    get root_url
    assert_difference 'Comrade.count', -1 do
      delete comrade_request_path(@jack_and_jill)
    end
    refute_includes @jack.pending_comrades, @jill
  end

  test "should delete an existing comrade relationship" do
    sign_in @jack
    get root_url
    patch comrade_request_path(@jack_and_jill)
    delete comrade_path(@jack_and_jill)
    refute_includes @jack.comrades, @jill
  end

  # Worthy flow
  test "should create a worthy" do
    sign_in @jill
    get root_url
    patch comrade_request_path(@jack_and_jill)
    post posts_path, params: { post: { content: 'content' }}
    sign_out @jill
    sign_in @jack
    get root_url
    assert_difference 'Worthy.count', 1 do
      post = @jill.posts.first
      post post_worthies_path(post.id)
      assert_equal 1, post.worthies.count
    end
  end

  test "should delete a worthy" do
    sign_in @jill
    get root_url
    patch comrade_request_path(@jack_and_jill)
    post posts_path, params: { post: { content: 'content' }}
    sign_out @jill
    sign_in @jack
    get root_url
    post = @jill.posts.first
    worthy = post.worthies.build(user_id: @jill.id)
    worthy.save!
    assert_difference 'Worthy.count', -1 do
      delete worthy_path(worthy.id)
      assert_equal 0, post.worthies.count
    end
  end

  # Comments
  test "should post a comment on own post" do
    sign_in @jack
    get root_url
    assert_equal 0, @jack_post.comments.count
    assert_difference 'Comment.count', 1 do
      post post_comments_path(@jack_post), params: { comment: { content: 'comment' }}
      follow_redirect!
    end
    assert_equal 1, @jack_post.comments.count
  end

  test "should post a comment on comrades post" do
    sign_in @jack
    get root_url
    patch comrade_request_path(@jack_and_jill)
    assert_equal 0, @jill_post.comments.count
    assert_difference 'Comment.count', 1 do
      post post_comments_path(@jill_post), params: { comment: { content: 'comment' }}
      follow_redirect!
    end
    assert_equal 1, @jill_post.comments.count
  end

  test "should flash alert if non-friend tries to post a comment" do
    sign_in @john
    get root_url
    refute_includes @john.comrades, @jack
    post post_comments_path(@jack_post), params: { comment: { content: 'comment' }}
    assert_redirected_to root_url
    assert_not flash.empty?
  end
end
