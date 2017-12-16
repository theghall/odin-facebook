class Comrade < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :pending_follower, class_name: 'User', foreign_key: 'follower_id'
  belongs_to :followed, class_name: 'User'
  validates :follower_id, presence: true
  validates :followed_id, presence: true

  scope :request, -> { where(:accepted => nil) }
  scope :accepted, -> { where(:accepted => true) }

  def self.from_profile(followed_id, follower_id)
    where(followed_id: followed_id, follower_id: follower_id).first
  end


end

