class User < ActiveRecord::Base
  devise :database_authenticatable, authentication_keys: [:username]
  devise :recoverable
  
  attr_accessible :facebook_token
  attr_accessible :first_name
  attr_accessible :inviter_id
  attr_accessible :last_name
  attr_accessible :mobile
  attr_accessible :password
  attr_accessible :public
  attr_accessible :publish_to_facebook
  attr_accessible :publish_to_twitter
  attr_accessible :sms_notifications
  attr_accessible :token
  attr_accessible :twitter_token
  attr_accessible :username
  
  has_many :followeeings, class_name: "Following", foreign_key: :follower_id
  has_many :followees, through: :followeeings
  has_many :followerings, class_name: "Following", foreign_key: :followee_id
  has_many :followers, through: :followerings
  
  before_save { |u| u.token = generate_token if token.blank? }
  
  validates :mobile, presence: true
  validates :mobile, uniqueness: true
  validates :username, uniqueness: true, allow_blank: true
  
  private
  
  def generate_token
    loop do
      auth_token = Devise.friendly_token
      break auth_token unless User.where{ token == my{auth_token} }.count > 0
    end
  end
end
