class User < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader
  devise :database_authenticatable, authentication_keys: [:username]
  devise :recoverable
  
  attr_accessible :avatar, :facebook_token, :first_name, :inviter, :inviter_id, :last_name, :mobile, :password, :public, :publish_to_facebook, :publish_to_twitter, :sms_notifications, :token, :twitter_token, :username
  
  belongs_to :inviter, class_name: "User", foreign_key: "inviter_id"
  
  has_many :alerts
  has_many :challenges, class_name: "Thumbwar", foreign_key: "challengee_id"
  has_many :followeeings, class_name: "Following", foreign_key: :follower_id
  has_many :followees, through: :followeeings
  has_many :followerings, class_name: "Following", foreign_key: :followee_id
  has_many :followers, through: :followerings
  has_many :thumbwars, foreign_key: "challenger_id"
  has_many :watchings
  
  before_validation :generate_username, if: Proc.new{ |u| u.username.blank? }
  before_save { |u| u.token = generate_token if token.blank? }
  after_create :inviter_stuff, if: Proc.new{ |u| u.inviter }
  
  validates :mobile, presence: true, uniqueness: true, length: {in: 11..15}, format: {with: /\A\d+\z/}
  validates :username, uniqueness: true, allow_blank: true
  
  def to_s
    if username.present?
      username
    elsif first_name.present? || last_name.present?
      "#{first_name} #{last_name}"
    else
      ""
    end
  end

  def follows?(user)
    user.followerings.where{ followee_id == my{user.id} }.count > 0
  end
  
  private

  def generate_username
    self.username = "tWar_#{id}"
  end
  
  def generate_token
    loop do
      auth_token = Devise.friendly_token
      break auth_token unless User.where{ token == my{auth_token} }.count > 0
    end
  end
  
  def inviter_stuff
    inviter.alerts.create(alertable: self, body: "Someone you invited just joined Thumbwar!")
    inviter.followers << self
    self.followers << inviter
  end
end
