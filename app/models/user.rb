class User < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader
  
  devise :database_authenticatable, authentication_keys: [:username]
  devise :recoverable
  
  attr_accessible :avatar, :facebook_token, :first_name, :inviter, :inviter_id, :last_name, :mobile, :public, 
    :publish_to_facebook, :publish_to_twitter, :sms_notifications, :token, :twitter_token, :username, :verification_url

  attr_accessor :verification_url

  belongs_to :inviter, class_name: "User", foreign_key: "inviter_id"
  
  has_many :alerts
  has_many :challenges, class_name: "Thumbwar", foreign_key: "challengee_id", dependent: :destroy
  has_many :followeeings, class_name: "Following", foreign_key: :follower_id, dependent: :destroy
  has_many :followees, through: :followeeings
  has_many :followerings, class_name: "Following", foreign_key: :followee_id, dependent: :destroy
  has_many :followers, through: :followerings
  has_many :thumbwars, foreign_key: "challenger_id", dependent: :destroy
  has_many :watchings, dependent: :destroy
  

  validates :mobile, presence: true, uniqueness: true, length: {in: 11..15}, format: {with: /\A\d+\z/}
  validates :username, uniqueness: true, allow_blank: true
  
  before_save { |u| u.token = generate_token if token.blank? }
  before_save :assign_avatar, unless: Proc.new{ |u| u.avatar.present? }
  after_save :complete_invitation_acceptance, if: Proc.new{ |u| u.inviter_id.present? && u.username_was.blank? && u.username.present? }
  after_save :send_verification_code_wrapper, if: Proc.new{ |u| u.username.present? && !u.verified? }
  after_create :send_invitation_wrapper, if: Proc.new{ |u| u.inviter_id.present? }
  
  def to_s
    display_name    
  end
  
  def assign_avatar
    self.remote_avatar_url = "#{ENV['HOST']}/images/avatars/#{(1..28).to_a.sample}.png"
  end
  handle_asynchronously :assign_avatar

  def display_name
    if display_full_name? && (first_name.present? || last_name.present?)
      "#{first_name} #{last_name}"
    elsif username.present?
      username
    else
      "New Guest"
    end
  end

  def display_full_name?
    true #This will be a preference in later versions
  end

  def follows?(user)
    user.followerings.where{ followee_id == my{user.id} }.count > 0
  end

  def twitter
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = twitter_token
      config.access_token_secret = twitter_secret
    end
  end

  def facebook
    fa_token = facebook_token
    if facebook_expires_at && facebook_expires_at < Time.now
      oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
      new_access_info = oauth.exchange_access_token_info(facebook_token)

      new_access_token = new_access_info["access_token"]
      new_access_expires_at = DateTime.now + new_access_info["expires"].to_i.seconds
      
      fa_token = new_access_token

      update_attributes!(:facebook_token => new_access_token,
                              :facebook_expires_at => new_access_expires_at )
    end
    @facebook ||= Koala::Facebook::API.new(fa_token)
    block_given? ? yield(@facebook) : @facebook

    rescue Koala::Facebook::APIError => e
      logger.info e.to_s
      nil
  end

  def send_verification_code(verification_url=nil)
    code = rand.to_s[2..7]
    
    update_column(:verification_code, code)
    
    client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    number = ENV['TWILIO_NUMBERS'].split(",").sample

    body = verification_url.present? ? 
      "Please click this link to verify your ThumbWar mobile number #{verification_url}?code=#{verification_code}" :
      "Please enter your verification code to confirm your ThumbWar mobile number: #{code}"

    client.account.sms.messages.create(
      from: "+1#{number}",
      to: "+#{mobile}",
      body: body
    )
  end
  handle_asynchronously :send_verification_code
  
  def send_reset_password_token(url)
    token = generate_reset_password_token
    update_column(:reset_password_token, token)
    update_column(:reset_password_sent_at, Time.now)
    
    client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    number = ENV['TWILIO_NUMBERS'].split(",").sample

    client.account.sms.messages.create(
      from: "+1#{number}",
      to: "+#{mobile}",
      body: "Reset your ThumbWar password #{url}?reset_password_token=#{token}&mobile=#{mobile}"
    )
  end
  handle_asynchronously :send_reset_password_token

  protected

  def send_invitation(verification_url=nil)
    code = rand.to_s[2..7]
    
    update_column(:verification_code, code)

    client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    number = ENV['TWILIO_NUMBERS'].split(",").sample

    body = "#{inviter} wants you to join ThumbWar. Click the link to get started: #{verification_url}?code=#{code}&mobile=#{mobile}"

    client.account.sms.messages.create(
      from: "+1#{number}",
      to: "+#{mobile}",
      body: body
    )
  end
  handle_asynchronously :send_invitation
  
  def generate_token
    loop do
      auth_token = Devise.friendly_token
      break auth_token unless User.where{ token == my{auth_token} }.count > 0
    end
  end
  
  def generate_reset_password_token
    loop do
      auth_token = Devise.friendly_token
      break auth_token unless User.where{ reset_password_token == my{auth_token} }.count > 0
    end
  end
  
  def complete_invitation_acceptance
    
    self.followers << inviter
    inviter.followers << self
    
    inviter.alerts.create(alertable: self, body: "Someone you invited just joined Thumbwar!")
  end

  def send_verification_code_wrapper
    send_verification_code(verification_url)
  end

  def send_invitation_wrapper
    send_invitation(verification_url)
  end
  

end
