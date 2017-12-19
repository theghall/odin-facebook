require 'test_helper'

class ServerFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @jack = users(:jack)
    @john = users(:john)
    @jill = users(:jill)
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
end
