require 'test_helper'

class ClientFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @jack = users(:jack)
    @jill = users(:jill)
    @john = users(:john)
    @julian = users(:julian)
    @jack_and_jill = comrades(:jack_and_jill)
    @jack_and_john = comrades(:jack_and_john)
    @jack_post = posts(:jack_post)
    @jill_post = posts(:jill_post)
  end

  #header
  test "should have header with all links" do
    sign_in @jack
    get root_url
    # User
    assert_select 'a[href=?]', profiles_path, { count: 1 }
    # Comrade requests
    assert_select 'a[href=?]', comrade_requests_path, { count: 1 }
    # Comrades
    assert_select 'a[href=?]', comrades_path, { count: 1 }
    # Home
    assert_select 'a[href=?]', root_path, { count: 1 }
    # Accounts
    assert_select 'a[href=?]', '#', { count: 1, text: 'Account' } 
    assert_select 'a[href=?]', edit_user_registration_path, { count: 1 }
    assert_select 'a[href=?]', user_registration_path, { count: 1 }
    assert_select 'a[href=?]', destroy_user_session_path, { count: 1 }
    # About
    assert_select 'a[href=?]', about_path, { count: 1 }
  end

  # user area
  test "should display users profile pic and name" do
    sign_in @jack
    get root_url
    assert_select 'img[src=?]', /odin.*\.png/, { count: 1 }
    assert_select 'div#user-area-info > span', { text: @jack.name, count: 1 }
  end

  test "should display a form for posting with a submit button" do
    sign_in @jack
    get root_url
    assert_select 'form[action=?] textarea', posts_path, { count: 1 }

    assert_select 'form[action=?]', posts_path do 
      assert_select "input[type=submit][name='commit']"
    end
  end

  # Users
  test "should display all users" do
    sign_in @jack
    get root_url
    get profiles_path
    User.all.each do |u|
      assert_select 'a[href=?]', profile_path(u), { count: 1 } unless u == @jack
    end
  end

  # Comrade requests
  test "should display all comrade requests" do
    sign_in @jack
    get root_url
    @jack.pending_comrades << @jill
    @jack.pending_comrades << @john
    assert_not @jack.requests.empty?
    get comrade_requests_path('requests')
    @jack.requests.each do |r|
      assert_select 'form[action=?]', comrade_request_path(r), { count: 2} do
       assert_select "input[type=hidden][value=patch]", { count: 1 }
       assert_select "input[type=hidden][value=delete]", { count: 1 }
      end
    end
  end

  # Comrades
  test "should display all comrades" do
    sign_in @jack
    get root_url
    patch comrade_request_path(@jack_and_jill)
    patch comrade_request_path(@jack_and_john)
    @jack.reload
    assert_not @jack.comrades.empty?
    get comrades_path
    @jack.comrades.each do |c|
      r = Comrade.from_profile(@jack.id, c.id)
      assert_select 'form[action=?]', comrade_path(r), { value: 'delete', count: 1 }
    end
  end

  # feed
  test "should display posts for user" do
    sign_in @jack
    get root_url
    @jack.posts.each do |p|
      assert_select 'div.post-content', { text: p.content, count: 1 }
    end
  end

  test "should display abutton with link to 'worthy' a post" do
    sign_in @jack
    get root_url
    patch comrade_request_path(@jack_and_jill)
    get root_url
    assert_select 'form[action=?]', post_worthies_path(@jill_post), { count: 1 }
  end

  test "should display a button with link to 'un-worthy' a post" do
    sign_in @jack
    get root_url
    patch comrade_request_path(@jack_and_jill)
    get root_url
    post post_worthies_path(@jill_post)
    follow_redirect!
    assert_select 'form[action=?]', worthy_path(worthy_id(@jill_post, @jack)), { count: 1 }
  end

  # Users
  test "should display a list of users" do
    sign_in @jack
    get root_url
    get profiles_path
    User.all.each do |u|
      # TODO: assert profile pic
      assert_select 'a[href=?]', profile_path(u), { html: u.name, count: 1} unless u == @jack
    end
  end

  # Profile
  test "should display a add comrade button with correct action" do
    sign_in @jack
    get root_url
    get profile_path(@julian)
    assert_select 'form[action=?]', comrade_requests_path do
      assert_select "input[type=hidden][name='comrade[requestee]']", { value: @julian.id }
      assert_select "input[type=submit][value='Add Comrade']"
    end
  end

  test "should display a cancel request button with correct action" do
    sign_in @jack
    get root_url
    get profile_path(@julian)
    post comrade_requests_path, params: { comrade: { requestee: @julian.id }}
    follow_redirect!
    assert_select 'form[action=?]', comrade_request_path(@julian.requests.first) do
      assert_select "input[type=submit][value='Cancel comrade request']" 
    end
  end

  test "should display a delete comrade button with correct action for both comrades" do
    sign_in @jack
    get root_url
    patch comrade_request_path(@jack_and_jill)
    follow_redirect!
    get profile_path(@jill)
    assert_select 'form[action=?]', comrade_path(@jack_and_jill) do
      assert_select "input[type=submit][value='Delete comrade']"
    end
    sign_out @jack
    sign_in @jill
    get root_url
    get profile_path(@jack)
    assert_select 'form[action=?]', comrade_path(@jack_and_jill) do
      assert_select "input[type=submit][value='Delete comrade']"
    end
  end

  # Comments
  test "should display comment form below a post" do
    sign_in @jack
    get root_url
    assert_select 'div form[action=?]', post_comments_path(@jack_post) do
      assert_select "input[type=submit][value='Submit']"
    end
  end

  test "should display comment on own post" do
    comment = 'lorem ipso facto corpas'
    sign_in @jack
    get root_url
    post post_comments_path(@jack_post), params: { comment: { content: comment }}
    follow_redirect!
    assert_match comment, response.body
  end

  test "should display comment on friends post" do
    comment = 'hocum pocus ipso facto lorem'
    sign_in @jack
    get root_url
    patch comrade_request_path(@jack_and_jill)
    post post_comments_path(@jill_post), params: { comment: { content: comment }}
    follow_redirect!
    assert_match comment, response.body
  end
end
