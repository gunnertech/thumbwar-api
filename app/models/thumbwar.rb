class Thumbwar < ActiveRecord::Base
  acts_as_commentable
  alias_attribute :comments, :comment_threads
  
  attr_accessible :challengee, :challengee_id, :challenger, :challenger_id, :body, :expires_in, :status, :wager, 
    :accepted, :winner_id, :audience_members, :url
  attr_accessor :audience_members, :status
  
  belongs_to :challengee, class_name: "User", foreign_key: "challengee_id"
  belongs_to :challenger, class_name: "User", foreign_key: "challenger_id"
  
  has_many :watchings
  has_many :watchers, through: :watchings, source: :user
  
  validates :challengee_id, presence: true
  validates :challenger_id, presence: true
  validates :body, presence: true
  

  after_create :complete_url, if: Proc.new { |tw| tw.url.present? }
  after_create :send_challenge_alert
  after_create :send_notice_to_audience_members_wrapper, if: Proc.new { |tw| tw.audience_members.present? }
  after_save :make_connections, if: Proc.new { |tw| tw.accepted? } 
  after_update :send_winner_alert, if: Proc.new { |tw| tw.winner_id_changed? }
  
  def status
    if accepted.nil?
      "pending"
    else
      if winner_id.nil?
        accepted ? "accepted" : "rejected"
      else
        winner_id == 0 ? "push" : winner_id == challenger_id ? "win" : "loss"
      end
    end
  end
  
  protected

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
  
  def send_winner_alert
    challengee.alerts.create!(alertable: self, body: winner_id == 0 ? "One of your Thumbwars is a push." : "You #{(winner_id == challengee_id) ? "lost" : "won"} a Thumbwar!")
    watchers.each { |u| u.alerts.create!(alertable: self, body: "A Thumbwar you're watching just ended!") }
  end

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
