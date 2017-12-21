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
    refute_includes @john.pending_comrades, @jack
    refute_includes @john.comrades_prime, @jack
    refute_includes @jack.comrades_double_prime, @john
    assert_difference 'Comrade.count', 1 do
      post comrades_path, params: { comrade: { requestee: @john.id }}
    end
    assert_includes @john.pending_comrades, @jack
    refute_includes @john.comrades_prime, @jack
    refute_includes @jack.comrades_double_prime, @john
  end

  test "should have user  user" do
    sign_in @jack
    get root_url
    refute_includes @jack.comrades_prime, @jill
    refute_includes @jill.comrades_double_prime, @jack
    patch comrade_path(@jack_and_jill.id)
    refute_includes @jack.pending_comrades, @jill
    assert_includes @jack.comrades_prime, @jill
    assert_includes @jill.comrades_double_prime, @jack
  end

  test "should delete pending comrade request" do
    sign_in @jack
    get root_url
    assert_difference 'Comrade.count', -1 do
      delete comrade_path(@jack_and_jill.id)
    end
    refute_includes @jack.pending_comrades, @jill
  end

  # Worthy flow
  test "should create a worthy" do
    sign_in @jill
    get root_url
    patch comrade_path(@jack_and_jill.id)
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
    patch comrade_path(@jack_and_jill.id)
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

  test "should post a comment on friends post" do
    sign_in @jack
    get root_url
    patch comrade_path(@jack_and_jill.id)
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
