class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         # :confirmable, :lockable, :timeoutable and :omniauthable

  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :username
  attr_accessible :token
  
  before_save { |u| u.token = generate_token if token.blank? }
  
  private
  
  def generate_token
    loop do
      token = Devise.friendly_token
      break token unless User.where{ token == token }.count > 0
    end
  end
end
