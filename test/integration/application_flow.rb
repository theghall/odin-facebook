require 'test_helper'

class ApplicationFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:jack)
  end

  # Posting flow
  test "should increase post count by 1 after posting" do
    sign_in @user
    get root_url
    assert_difference 'Post.count', 1 do
      post post_path, params: { post: { content: 'content' }}
    end
  end

end
