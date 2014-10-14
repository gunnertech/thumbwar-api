class User < ActiveRecord::Base
  devise :database_authenticatable, authentication_keys: [:username]
  devise :recoverable
  
  attr_accessible :facebook_token, :first_name, :inviter_id, :last_name, :mobile, :password, :public, :publish_to_facebook, :publish_to_twitter, :sms_notifications, :token, :twitter_token, :username
  
  has_many :alerts
  has_many :challenges, class_name: "Thumbwar", foreign_key: "challengee_id"
  has_many :followeeings, class_name: "Following", foreign_key: :follower_id
  has_many :followees, through: :followeeings
  has_many :followerings, class_name: "Following", foreign_key: :followee_id
  has_many :followers, through: :followerings
  has_many :thumbwars, foreign_key: "challenger_id"
  has_many :watchings
  
  before_save { |u| u.token = generate_token if token.blank? }
  after_create :send_alerts
  
  validates :mobile, presence: true
  validates :mobile, uniqueness: true
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
  
  private
  
  def generate_token
    loop do
      auth_token = Devise.friendly_token
      break auth_token unless User.where{ token == my{auth_token} }.count > 0
    end
  end
  
  def send_alerts
    
  end
end
