require 'test_helper'

class ServerFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @jack = users(:jack)
    @jack_post = posts(:jack_post)
    @john = users(:john)
    @jill = users(:jill)
    @jane = users(:jane)
    @jill_post = posts(:jill_post)
    @jack_and_jill = comrades(:jack_and_jill)
    @joe_and_jack = comrades(:joe_and_jack)
    @julian = users(:julian)
  end

  # Test dependent destroy
  test "should not raise exeception when canceling acct" do
    sign_in @jack
    patch comrade_request_path(@jack_and_jill)
    patch comrade_request_path(@joe_and_jack)
    post post_worthies_path(@jack_post)
    post post_comments_path(@jack_post), params: { comment: { content: 'comment' }}
    @jack.reload
    assert @jack.sent_requests.any?
    assert @jack.requests.any?
    assert @jack.relationships_prime.any?
    assert @jack.relationships_double_prime.any?
    assert @jack.posts.any?
    assert @jack.worthies.any?
    assert @jack.comments.any?
    assert_nothing_raised do
      assert_difference 'User.count', -1 do
        @jack.destroy
      end
    end 
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
    refute_includes @jane.pending_comrades, @jack
    refute_includes @jane.comrades, @jack
    assert_difference 'Comrade.count', 1 do
      post comrade_requests_path, params: { comrade: { requestee: @jane.id }}
    end
    assert_includes @jane.pending_comrades, @jack
    refute_includes @jane.comrades, @jack
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

  # Race conditions
  test "should catch race condition where two users make comrade requests to each other" do
    begin
      assert_equal 5, ActiveRecord::Base.connection.pool.size
      concurrency_level = 2
      should_wait = true

      status = {}
      wait_post = [true, true]

      threads = Array.new(concurrency_level) do |i|
        Thread.new do
          # wait for both threads to be initialized
          true while should_wait
            if i == 0
              sign_in @jack
              get root_url
              # wait for other thread to login and get root_url
              wait_post[1] = false
              true while wait_post[0]
              post comrade_requests_path, params: { comrade: { requestee: @jane.id }}
              sign_out @jack
              @jack.reload
              status[i] = @jill.pending_comrades.include?(@jack)
            elsif i == 1
              sign_in @jane
              get root_url
              # wait for other thread to login and get root_url
              wait_post[0] = false
              true while wait_post[1]
              post comrade_requests_path, params: { comrade: { requestee: @jack.id }}
              sign_out @jane
              @jane.reload
              status[i] = @jack.pending_comrades.include?(@jill)
            end
        end
      end
      should_wait = false
      threads.each(&:join)

      assert status[0] != status[1]
    ensure
      ActiveRecord::Base.connection_pool.disconnect!
    end
  end
end
