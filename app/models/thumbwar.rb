class Thumbwar < ActiveRecord::Base
  mount_uploader :photo, PhotoUploader
  acts_as_commentable
  alias_attribute :comments, :comment_threads
  
  attr_accessible :challengee, :challengee_id, :challenger, :challenger_id, :body, :expires_in, :status, :wager, 
    :accepted, :winner_id, :audience_members, :url, :photo, :remote_photo_url, :publish_to_twitter, :publish_to_facebook
    
  attr_accessor :audience_members, :status, :expires_in
  
  belongs_to :challengee, class_name: "User", foreign_key: "challengee_id"
  belongs_to :challenger, class_name: "User", foreign_key: "challenger_id"
  
  has_many :watchings
  has_many :watchers, through: :watchings, source: :user
  has_many :alerts, as: :alertable
  
  validates :challengee_id, presence: true
  validates :challenger_id, presence: true
  validates :body, presence: true

  before_validation :set_expires_at, if: Proc.new{ |tw| tw.expires_in.present? }
  

  after_create :post_to_twitter, if: Proc.new{ |tw| tw.publish_to_twitter? }
  after_create :post_to_facebook, if: Proc.new{ |tw| tw.publish_to_facebook? }
  after_create :complete_url, if: Proc.new { |tw| tw.url.present? }
  after_create :send_challenge_alert
  after_create :send_notice_to_audience_members_wrapper, if: Proc.new { |tw| tw.audience_members.present? }
  after_save :make_connections, if: Proc.new { |tw| tw.accepted? } 
  after_update :send_outcome_alert, if: Proc.new { |tw| tw.winner_id_changed? }
  after_create :send_expiring_soon_alert, if: Proc.new { |tw| tw.expires_at.present? && tw.expires_at > 20.minutes.from_now }
  
  class << self
    def mine(user=nil)
      joins{ watchings.outer }.where{ (challengee_id == my{user.id}) | (challenger_id == my{user.id}) | (watchings.user_id == my{user.id}) }
    end
    
    def public(user=nil)
      where{ public == true }
    end
    
    def wins(user=nil)
      where{ winner_id == challenger_id }
    end
    
    def pushes(user=nil)
      where{ winner_id == 0 }
    end
    
    def losses(user=nil)
      where{ winner_id == challengee_id }
    end
    
    def challengee_accepted(user)
      where{ (challengee_id == my{user.id}) & (accepted == true) }
    end
    
    def challengee_rejected(user)
      where{ (challengee_id == my{user.id}) & (accepted == false) }
    end
    
    def challengee_pending(user)
      where{ (challengee_id == my{user.id}) & (accepted == nil) & (expires_at >= my{Time.now}) }
    end
    
    def challenger_accepted(user)
      where{ (challenger_id == my{user.id}) & (accepted == true) }
    end

    def challenger_rejected(user)
      where{ (challenger_id == my{user.id}) & (accepted == false) }
    end

    def challenger_pending(user)
      where{ (challenger_id == my{user.id}) & (accepted == nil) & (expires_at >= my{Time.now}) }
    end
  end
  
  def status
    if accepted.nil?
      if expires_at.present? && Time.now >= expires_at
        "expired"
      else
        "pending"
      end
    else
      if winner_id.nil?
        accepted ? "accepted" : "rejected"
      else
        winner_id == 0 ? "push" : winner_id == challenger_id ? "win" : "loss"
      end
    end
  end
  
  def minutes_remaining
    ((expires_at - Time.now)/60).round if expires_at
  end
  
  protected

  def set_expires_at
    self.expires_at = expires_in.minutes.from_now
  end

  def expiring_soon?
    return false if status != 'pending' || expires_at.nil? || expires_at - created_at < 20.minutes
    
    expires_at <= 10.minutes.from_now
  end

  def send_expiring_soon_alert
    challengee.alerts.create!(alertable: self, body: "Your Thumbwar is about to expire!") if expiring_soon?
  end
  handle_asynchronously :send_expiring_soon_alert, run_at: Proc.new { |tw| (tw.expires_in.minutes - 10.minutes).from_now }

  def send_expired_alert
    challengee.alerts.create!(alertable: self, body: "Your Thumbwar expired!") if status == 'expired'
  end
  handle_asynchronously :send_expired_alert, run_at: Proc.new { |tw| (tw.expires_in.minutes + 1.minute).from_now }

  def twitter_challengee_text
    challengee.twitter_username || challengee.display_name
  end

  def post_to_twitter
    challenger.twitter.update("#{body} $#{wager} #{url} /cc #{twitter_challengee_text}" ) rescue nil
  end
  handle_asynchronously :post_to_twitter

  def post_to_facebook
    challenger.facebook.put_connections("me", "links", 
      link: url.gsub(/localhost/,"test.com"),
      name: "Thumbwar: #{challengee.display_name}",
      message: body,
      picture: photo.url
    )
  end
  handle_asynchronously :post_to_facebook

  def complete_url
    update_column(:url, url.gsub(/\{id\}/,id.to_s))
  end

  def make_connections
    challengee.followers << challenger unless challengee.follows?(challenger)
    challenger.followers << challengee unless challenger.follows?(challengee)
  end
  
  def send_challenge_alert
    challengee.alerts.create!(alertable: self, body: "#{challenger.to_s.blank? ? 
      "You've been challenged" : 
      "#{challenger.first_name} #{challenger.last_name} has challenged you"} 
      to a Thumbwar!".squish)
  end
  
  def send_outcome_alert
    challengee.alerts.create!(alertable: self, body: winner_id == 0 ? "One of your Thumbwars is a push." : "You #{(winner_id == challengee_id) ? "won" : "lost"} a Thumbwar!")
    watchers.each { |u| u.alerts.create!(alertable: self, body: "A Thumbwar you're watching just ended!") }
  end
  handle_asynchronously :send_outcome_alert

  def send_notice_to_audience_members_wrapper
    send_notice_to_audience_members(audience_members)    
  end

  def send_notice_to_audience_members(audience_members)
    client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    audience_members.each do |user|
      number = ENV['TWILIO_NUMBERS'].split(",").sample
      client.account.sms.messages.create(
        from: "+1#{number}",
        to: "+#{user["mobile"]}",
        body: "#{challenger} wants you to see a Thumbwar. #{url}"
      )
    end
  end
  handle_asynchronously :send_notice_to_audience_members

end
