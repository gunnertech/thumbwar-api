class User < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader
  
  devise :database_authenticatable, authentication_keys: [:username]
  devise :recoverable
  
  attr_accessible :avatar, :facebook_token, :first_name, :inviter, :inviter_id, :last_name, :mobile, :public, 
    :publish_to_facebook, :publish_to_twitter, :sms_notifications, :twitter_token, :username, :verification_url, 
    :email, :facebook_id, :remote_avatar_url

  attr_accessor :verification_url, :skip_confirmation_code

  belongs_to :inviter, class_name: "User", foreign_key: "inviter_id"
  
  has_many :alerts, dependent: :destroy
  has_many :challenges, dependent: :destroy
  has_many :thumbwar_challenges, through: :challenges, class_name: "Thumbwar", foreign_key: :thumbwar_id
  has_many :followeeings, class_name: "Following", foreign_key: :follower_id, dependent: :destroy
  has_many :followees, through: :followeeings
  has_many :followerings, class_name: "Following", foreign_key: :followee_id, dependent: :destroy
  has_many :followers, through: :followerings
  has_many :thumbwars, foreign_key: "challenger_id", dependent: :destroy
  has_many :watchings, dependent: :destroy
  has_many :devices, dependent: :destroy
  
  

  validates :mobile, presence: true, uniqueness: true, length: {in: 11..15}, format: {with: /\A\d+\z/}, allow_nil: true
  validates :username, uniqueness: true
  validates :facebook_id, presence: true, uniqueness: true, allow_blank: true
  
  before_validation :generate_username, on: :create, if: Proc.new{ |u| u.username.blank? }
  before_validation :standardize_mobile, if: Proc.new{ |u| u.mobile.changed? && u.mobile.present? }
  
  before_save { |u| u.token = generate_token if token.blank? }
  
  after_save :assign_avatar, unless: Proc.new{ |u| u.avatar.present? || u.remote_avatar_url.present? }
  after_save :complete_invitation_acceptance, if: Proc.new{ |u| u.inviter_id.present? && u.facebook_id_was.blank? && u.facebook_id.present? }
  
  after_create :send_invitation_wrapper, if: Proc.new{ |u| u.inviter_id.present? }
  after_create :create_welcome_alert
  
  class << self
    def find_by_username_or_id(id)
      User.where{ lower(username) == my{id.to_s.downcase} }.first || find(id)
    end
  end
  
  
  def to_s
    display_name
  end
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def assign_avatar
    self.skip_confirmation_code = true
    self.remote_avatar_url = "#{ENV['HOST']}/images/avatars/#{(1..28).to_a.sample}.png"
    self.save!
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

  protected
  
  def generate_username(name = nil, attempt = nil)
    name = name || "#{first_name}#{last_name}"
    name = "#{name}#{attempt}" if attempt
    
    if User.where{ username == my{name}}.count == 0
      self.username = name
    else
      attempt = attempt ? attempt + 1 : 1
      generate_username(name,attempt)
    end
  end

  def send_invitation(verification_url=nil)
    if mobile
      body = "#{inviter} wants you to join ThumbWar. Click the link to get started: #{verification_url}?mobile=#{mobile}"
      client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      number = ENV['TWILIO_NUMBERS'].split(",").sample

      client.account.sms.messages.create(
        from: "+1#{number}",
        to: "+#{mobile}",
        body: body
      )
    else
      body = "#{inviter} wants you to join ThumbWar. Click the link to get started: #{verification_url}?email=#{email}"
      ActionMailer::Base.mail(
        from: (inviter.email||"no-reply@thumbwarapp.com"), 
        to: email, 
        subject: "#{inviter} wants you to join ThumbWar", 
        body: body
      ).deliver rescue nil
    end
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
    
    # self.followers << inviter
    inviter.followers << self
    
    inviter.alerts.create(alertable: self, body: "#{display_name} just joined Thumbwar!")
  end

  def send_invitation_wrapper
    send_invitation(verification_url)
  end
  
  def create_welcome_alert
    alerts.create(alertable: self, body: "Get started with ThumbWar! (This will be a three-step wizard that will walk new users through ThumbWar)")
  end
  
  def standardize_mobile
    if mobile.length == 10
      self.mobile = "1#{mobile}"
    end
    
    if mobile.length >= 11
      self.mobile = mobile.gsub(/\D/,"")
    end
  end
  

end
