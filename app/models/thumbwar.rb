class Thumbwar < ActiveRecord::Base
  acts_as_commentable
  alias_attribute :comments, :comment_threads
  
  attr_accessible :challengee, :challengee_id, :challenger, :challenger_id, :body, :expires_in, :status, :wager, :accepted, :winner_id
  
  belongs_to :challengee, class_name: "User", foreign_key: "challengee_id"
  belongs_to :challenger, class_name: "User", foreign_key: "challenger_id"
  
  has_many :watchings
  has_many :watchers, through: :watchings, source: :user
  
  validates :challengee_id, presence: true
  validates :challenger_id, presence: true
  validates :body, presence: true
  
  after_create :send_challenge_alert
  after_create :follow_challengee, unless: Proc.new { |tw| tw.challenger.follows?(tw.challengee) } 
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

  def follow_challengee
    challengee.followers << challenger
  end
  
  def send_challenge_alert
    challengee.alerts.create!(alertable: self, body: "#{challenger.to_s.blank? ? "You've been challenged" : "#{challenger.first_name} #{challenger.last_name} has challenged you"} to a Thumbwar!")
  end
  
  def send_winner_alert
    challengee.alerts.create!(alertable: self, body: winner_id == 0 ? "One of your Thumbwars is a push." : "You #{(winner_id == challengee_id) ? "lost" : "won"} a Thumbwar!")
    watchers.each { |u| u.alerts.create!(alertable: self, body: "A Thumbwar you're watching just ended!") }
  end
end
