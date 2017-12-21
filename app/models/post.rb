class Post < ApplicationRecord
  belongs_to :user
  has_many :worthies, dependent: :destroy
  has_many :reaction_users, through: :worthies, source: :user
  has_many :comments
  validates :content, presence: true
  default_scope -> { order(created_at: :desc) }
end
