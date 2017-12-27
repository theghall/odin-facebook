class Comrade < ApplicationRecord
  belongs_to :requestor, class_name: 'User', foreign_key: 'requestor_id'
  belongs_to :requestee, class_name: 'User', foreign_key: 'requestee_id'

  after_initialize :defaults

  validates :requestor_id, presence: true
  validates :requestee_id, presence: true
  validate :requestee_id, :no_inverse_relation

  scope :request, -> { where(:accepted => false) }
  scope :accepted, -> { where(:accepted => true) }

  def self.from_profile(id1, id2)
    where(requestor_id: id1, requestee_id: id2).or(Comrade.where(requestor_id: id2, requestee_id: id1)).first
  end

  private

    def defaults
      self.accepted = false if self.accepted.nil?
    end

    def no_inverse_relation
      request = Comrade.find_by(requestor_id: self.requestee_id, requestee_id: self.requestor_id)

      errors[:base] << 'A relation already exists with that user' unless request.nil?
    end

end

