class User < ApplicationRecord
  has_many :posts
  has_many :active_relationships, -> { accepted }, class_name: 'Comrade', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, -> { accepted }, class_name: 'Comrade', foreign_key: 'followed_id', dependent: :destroy
  has_many :passive_requests, -> { request }, class_name: 'Comrade', foreign_key: 'followed_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :pending_comrades, through: :passive_requests, source: :pending_follower
  after_initialize :defaults

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  mount_uploader :profile_pic, ProfilePicUploader

  def self.feed(user)
    feed_ids = Comrade.where(follower_id: user.id).pluck(:followed_id) << user.id

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

  def password_required?
    super && provider.blank?
  end

  def sent_welcome(sent)
    self.welcome_sent = sent
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def follow_pending?(other_user)
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
