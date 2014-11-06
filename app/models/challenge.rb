class Challenge < ActiveRecord::Base
  attr_accessible :status, :outcome, :thumbwar_id, :user_id, :challenger_id
  
  belongs_to :user
  belongs_to :thumbwar
  belongs_to :challenger, class_name: "User", foreign_key: 'challenger_id'
  
  after_create :create_challenge_alert, if: Proc.new{|c| c.status == 'pending' }
  
  after_update :create_outcome_alert, if: Proc.new{|c| c.outcome_changed? }
  
  after_save :create_status_alert, if: Proc.new{|c| c.status_changed? && c.status != 'pending' }
  
  protected
  
  def create_challenge_alert
    user.alerts.create!(alertable: thumbwar, body: "#{challenger.display_name} challenged you to a ThumbWar!")
  end
  
  def create_status_alert
    if status == 'accepted'
      user.followers << challenger unless user.followers.include?(challenger)
      challenger.followers << user unless challenger.followers.include?(user)
    end
    
    challenger.alerts.create!(alertable: thumbwar, body: "#{user.display_name} #{status} your ThumbWar!")
  end
  
  def create_outcome_alert
    user.alerts.create!(alertable: thumbwar, body: outcome == 'push' ? "One of your Thumbwars is a push." : "You #{(outcome == 'win') ? "won" : "lost"} a Thumbwar!")
  end
end
