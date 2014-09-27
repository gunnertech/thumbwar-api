class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         # :confirmable, :lockable, :timeoutable and :omniauthable

  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :username
  attr_accessible :authentication_token
  
  before_save { |u| u.authentication_token = generate_authentication_token if authentication_token.blank? }
  
  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where{ authentication_token == token }.count > 0
    end
  end
end
