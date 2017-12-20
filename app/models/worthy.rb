class Worthy < ApplicationRecord
  belongs_to :post
  belongs_to :user

  def self.from_feed(post, user)
    where(post_id: post.id, user_id: user.id).pluck(:id).first
  end
end
