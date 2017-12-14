require 'test_helper'

class SecurityFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:jack)
  end

  test "should render welcome page if not logged in" do
    get root_url
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render user page if logged in" do
    sign_in @user
    get root_url
    assert_template partial: 'static_pages/_user_page' 
  end

  test "should render welcome page if posting without login" do
    post posts_url, params: { post: { content: 'test' }}
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end
end