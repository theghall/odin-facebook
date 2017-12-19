class Comrade < ApplicationRecord
  belongs_to :requestor, class_name: 'User', foreign_key: 'requestor_id'
  belongs_to :requestee, class_name: 'User', foreign_key: 'requestee_id'

  validates :requestor_id, presence: true
  validates :requestee_id, presence: true

  scope :request, -> { where(:accepted => nil) }
  scope :accepted, -> { where(:accepted => true) }

  def self.from_profile(id1, id2)
    where(requestor_id: id1, requestee_id: id2).or(Comrade.where(requestor_id: id2, requestee_id: id1)).first
  end

end

