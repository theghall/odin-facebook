require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def setup
    @post = posts(:jack_post)
  end

  test "should not allow blank content" do
    @post.content = ""
    assert_not @post.valid?
  end
end
