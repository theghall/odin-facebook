class Post < ApplicationRecord
  belongs_to :user
  has_many :worthies, dependent: :destroy
  validates :content, presence: true
  default_scope -> { order(created_at: :desc) }
end
