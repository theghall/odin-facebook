class User < ApplicationRecord
  has_many :identities
  after_initialize :defaults

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  def self.from_omniauth(auth)
    user = self.where(provider: auth.provider, uid: auth.uid).first

    user = User.new unless user

    self.grab_oauth_values(auth, user)   
  end

  def password_required?
    super && provider.blank?
  end

  def sent_welcome(sent)
    self.welcome_sent = sent
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
      user.image = auth.info.image
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.skip_confirmation! if user.id.nil?
      user.save!
      user
    end
end
