class Challenge < ActiveRecord::Base
  attr_accessible :status, :outcome, :thumbwar_id, :user_id, :challenger_id
  
  belongs_to :user
  belongs_to :thumbwar
  belongs_to :challenger, class_name: "User", foreign_key: 'challenger_id'
  
  validates :status, inclusion: { in: %w(pending accepted rejected), message: "%{value} is not a valid status" }
  
  after_create :create_challenge_alert, if: Proc.new{|c| c.status == 'pending' }
  
  after_update :create_outcome_alert, if: Proc.new{|c| c.outcome_changed? }
  
  after_save :create_status_alert, if: Proc.new{|c| c.status_changed? && c.status != 'pending' }
  
  before_validation :set_challenger
  
  protected
  
  def set_challenger
    self.challenger_id = thumbwar.challenger_id
  end
  
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
    if outcome_was == 'win'
      user.decrement(:wins)
    elsif outcome_was == 'loss'
      user.decrement(:losses)
    elsif outcome_was == 'push'
      user.decrement(:pushes)
    end
    
    if outcome == 'win'
      user.increment(:wins)
    elsif outcome == 'loss'
      user.increment(:losses)
    elsif outcome == 'push'
      user.increment(:pushes)
    end
    
    user.save!
    user.alerts.create!(alertable: thumbwar, body: outcome == 'push' ? "One of your Thumbwars is a push." : "You #{(outcome == 'win') ? "won" : "lost"} a Thumbwar!")
  end
end
