require 'test_helper'

class ApplicationFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @jack = users(:jack)
    @john = users(:john)
    @jill = users(:jill)
    @jack_follows_jill = comrades(:jack_follows_jill)
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
    refute_includes @john.following, @jack
    refute_includes @jack.followers, @john
    assert_difference 'Comrade.count', 1 do
      post comrades_path, params: { comrade: { followed: @john.id }}
    end
    assert_includes @john.pending_comrades, @jack
    refute_includes @john.following, @jack
    refute_includes @jack.followers, @john
  end

  test "should have user following another user" do
    sign_in @jack
    get root_url
    refute_includes @jack.following, @jill
    refute_includes @jill.followers, @jack
    patch comrade_path(@jack_follows_jill.id)
    refute_includes @jack.pending_comrades, @jill
    assert_includes @jack.following, @jill
    assert_includes @jill.followers, @jack
  end

  test "should delete relationship" do
    sign_in @jack
    get root_url
    assert_difference 'Comrade.count', -1 do
      delete comrade_path(@jack_follows_jill.id)
    end
    refute_includes @jack.pending_comrades, @jill
  end
end
