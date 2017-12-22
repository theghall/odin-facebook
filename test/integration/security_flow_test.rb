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

  test "should render welcome page on profile show if not logged in" do
    get profile_url(@user)
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "shoud render welcome page for profiles if not logged in" do
    get profiles_url
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render welcome page for index of comrade requests if not logged in" do
    get comrade_requests_url
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render welcome page for making comrade request if not logged in" do
    post comrade_requests_url, params: { comrade: { requestee: 1 }}
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render welcome page for updating comrade request if not logged in" do
    patch comrade_request_url(1)
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render welcome page for deleting comrade request if not logged in" do
    delete comrade_request_url(1)
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render welcome page for viewing a list of comrades if not logged in" do
    get comrades_url
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render welcome page for deleing an existing comrade if not logged in" do
    delete comrade_path(1)
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render welcome page when trying to create a worthy and not logged in" do
    post post_worthies_url(1)
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render welcome page when trying to delete a worthy and not logged in" do
    delete worthy_url(1)
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end

  test "should render welcome page if post a comment and not logged in" do
    post post_comments_url(1), params: { comment: { content: 'comment' }}
    follow_redirect!
    assert_template partial: 'static_pages/_welcome'
  end
end
