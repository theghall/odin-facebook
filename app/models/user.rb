class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, through: :posts
  has_many :worthies, through: :posts
  has_many :relationships_prime, -> { accepted }, class_name: 'Comrade', foreign_key: 'requestor_id', dependent: :destroy
  has_many :relationships_double_prime, -> { accepted }, class_name: 'Comrade', foreign_key: 'requestee_id', dependent: :destroy
  has_many :comrades_prime, through: :relationships_prime, source: :requestee
  has_many :comrades_double_prime, through: :relationships_double_prime, source: :requestor
  has_many :sent_requests, -> {request}, class_name: 'Comrade', foreign_key: 'requestor_id', dependent: :destroy
  has_many :requests, -> { request }, class_name: 'Comrade', foreign_key: 'requestee_id', dependent: :destroy
  has_many :pending_comrades, through: :requests, source: :requestor
  

  after_initialize :defaults

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  mount_uploader :profile_pic, ProfilePicUploader

  def self.feed(user)
    feed_ids = user.comrades_prime.pluck(:requestee_id)

    feed_ids += user.comrades_double_prime.pluck(:requestor_id)

    feed_ids << user.id

    Post.where('user_id IN (:feed_ids)', feed_ids: feed_ids.sort!)
  end

  def self.from_omniauth(auth)
    user = self.where(provider: auth.provider, uid: auth.uid).first

    user = User.new unless user

    self.grab_oauth_values(auth, user)   
  end

  def self.all_but(user)
    where.not(id: user.id)
  end

  def comrades
    comrades_prime + comrades_double_prime
  end

  def common_comrades_with(user)
    comrades & user.comrades
  end

  def password_required?
    super && provider.blank?
  end

  def sent_welcome(sent)
    self.welcome_sent = sent
  end

  def comrade?(other_user)
    comrades_prime.include?(other_user) || comrades_double_prime.include?(other_user)
  end

  def comrade_pending?(other_user)
    other_user.pending_comrades.include?(self)
  end

  private
    
    def defaults
      self.welcome_sent = false if self.welcome_sent.nil?
    end

    def self.grab_oauth_values(auth, user)
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.remote_profile_pic_url = auth.info.image
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.skip_confirmation! if user.id.nil?
      user.save!
      user
    end
end
