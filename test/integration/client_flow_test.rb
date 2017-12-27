require 'test_helper'

class ClientFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @jack = users(:jack)
    @jill = users(:jill)
    @john = users(:john)
    @julian = users(:julian)
    @jane = users(:jane)
    @jorge = users(:jorge)
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
  test "should display all comrade requests with link to profile" do
    sign_in @jack
    get root_url
    @jack.pending_comrades << @jane
    @jack.pending_comrades << @jorge
    assert_not @jack.requests.empty?
    get comrade_requests_path('requests')
    @jack.requests.each do |r|
      assert_select 'a[href=?]', profile_path(r.requestor_id)
      assert_select 'form[action=?]', comrade_request_path(r), { count: 2} do
       assert_select "input[type=hidden][value=patch]", { count: 1 }
       assert_select "input[type=hidden][value=delete]", { count: 1 }
      end
    end
  end

  # Comrades
  test "should display all comrades with link to profile and a delete button" do
    sign_in @jack
    get root_url
    patch comrade_request_path(@jack_and_jill)
    patch comrade_request_path(@jack_and_john)
    @jack.reload
    assert_not @jack.comrades.empty?
    get comrades_path
    @jack.comrades.each do |c|
      r = Comrade.from_profile(@jack.id, c.id)
      assert_select 'a[href=?]', profile_path(c), { value: c.name, count: 1 }
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
    get profile_path(@jane)
    assert_select 'form[action=?]', comrade_requests_path do
      assert_select "input[type=hidden][name='comrade[requestee]']", { value: @jane.id }
      assert_select "input[type=submit][value='Add Comrade']"
    end
  end

  test "should display a cancel request button with correct action" do
    sign_in @jack
    get root_url
    get profile_path(@jane)
    post comrade_requests_path, params: { comrade: { requestee: @jane.id }}
    follow_redirect!
    assert_select 'form[action=?]', comrade_request_path(@jane.requests.first) do
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

  test "should display respond to request if friend request pending" do
    sign_in @jill
    get root_url
    assert_not @jill.pending_comrades.empty?
    get profile_path(@jack)
    assert_select 'form[action=?][method=get]', comrade_request_path(@jack_and_jill) do
      assert_select "input[type=submit][value='Respond to request']"
    end
    get comrade_request_path(@jack_and_jill)
    assert_select 'form[action=?]', comrade_request_path(@jack_and_jill), { count: 2} do
     assert_select "input[type=hidden][value=patch]", { count: 1 }
     assert_select "input[type=hidden][value=delete]", { count: 1 }
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

  # Race conditions
  test "should catch race condition where two users make comrade requests to each other" do
    skip 
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
              get profile_path(@jane)
              post comrade_requests_path, params: { comrade: { requestee: @jane.id }}
              follow_redirect!
              status[i] = @jill.pending_comrades.include?(@jack)
              unless status[i]
                assert_not flash.empty?
                assert_select 'form[action=?][method=get]', comrade_request_path(Comrade.from_profile(@jack.id, @jill.id)) do
                  assert_select "input[type=submit][value='Respond to request']"
                end
              end
              sign_out @jack
            elsif i == 1
              sign_in @jane
              get root_url
              # wait for other thread to login and get root_url
              wait_post[0] = false
              true while wait_post[1]
              get profile_path(@jack)
              post comrade_requests_path, params: { comrade: { requestee: @jack.id }}
              follow_redirect!
              status[i] = @jack.pending_comrades.include?(@jill)
              unless status[i]
                assert_not flash.empty?
                assert_select 'form[action=?][method=get]', comrade_request_path(Comrade.from_profile(@jill.id, @jack.id)) do
                  assert_select "input[type=submit][value='Respond to request']"
                end
              end
              sign_out @jane
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
