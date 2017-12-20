require 'test_helper'

class ClientFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @jack = users(:jack)
    @jill = users(:jill)
    @john = users(:john)
    @jack_and_jill = comrades(:jack_and_jill)
    @jill_post = posts(:jill_post)
  end

  #header
  test "should have header with all links" do
    sign_in @jack
    get root_url
    # User
    assert_select 'a[href=?]', profiles_path, { count: 1 }
    # Comrade requests
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
    patch comrade_path(@jack_and_jill.id)
    get root_url
    assert_select 'form[action=?]', post_worthies_path(@jill_post.id), { count: 1 }
  end

  test "should display a button with link to 'un-worthy' a post" do
    sign_in @jack
    get root_url
    patch comrade_path(@jack_and_jill.id)
    get root_url
    post post_worthies_path(@jill_post.id)
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
      assert_select 'a[href=?]', profile_path(u.id), { html: u.name, count: 1} unless u == @jack
    end
  end

  # Profile
  test "should display a add comrade button with correct action" do
    sign_in @jack
    get root_url
    get profile_path(@john)
      assert_select 'form[action=?]', comrades_path do
        assert_select "input[type=hidden][name='comrade[requestee]']", { value: @john.id }
        assert_select "input[type=submit][value='Add Comrade']"
      end
  end

  test "should display a cancel request button with correct action" do
    sign_in @jack
    get root_url
    get profile_path(@john)
    post comrades_path, params: { comrade: { requestee: @john.id }}
    follow_redirect!
    assert_select 'form[action=?]', comrade_path(@john.requests.first.id) do
      assert_select "input[type=submit][value='Cancel comrade request']" 
    end
  end

  test "should display a delete comrade button with correct action for both comrades" do
    sign_in @jack
    get root_url
    patch comrade_path(@jack_and_jill.id)
    follow_redirect!
    get profile_path(@jill)
    assert_select 'form[action=?]', comrade_path(@jack_and_jill.id) do
      assert_select "input[type=submit][value='Delete comrade']"
    end
    sign_out @jack
    sign_in @jill
    get root_url
    get profile_path(@jack)
    assert_select 'form[action=?]', comrade_path(@jack_and_jill.id) do
      assert_select "input[type=submit][value='Delete comrade']"
    end
  end
end
