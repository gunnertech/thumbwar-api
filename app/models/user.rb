class User < ActiveRecord::Base
  devise :database_authenticatable, authentication_keys: [:username]
  devise :recoverable

  attr_accessible :first_name
  attr_accessible :last_name
  attr_accessible :mobile
  attr_accessible :password
  attr_accessible :username
  attr_accessible :token
  
  has_many :followeeings, class_name: "Following", foreign_key: :follower_id
  has_many :followees, through: :followeeings
  has_many :followerings, class_name: "Following", foreign_key: :followee_id
  has_many :followers, through: :followerings
  
  before_save { |u| u.token = generate_token if token.blank? }
  
  validates :mobile, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  
  def email_changed?
    false
  end
  
  def email_required?
    false
  end
  
  private
  
  def generate_token
    loop do
      auth_token = Devise.friendly_token
      break auth_token unless User.where{ token == my{auth_token} }.count > 0
    end
  end
end
