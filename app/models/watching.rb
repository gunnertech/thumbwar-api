class Watching < ActiveRecord::Base
  attr_accessible :thumbwar_id, :user_id, :side
  
  belongs_to :thumbwar
  belongs_to :user
  
  validates :thumbwar_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :thumbwar_id, scope: :user_id
  
  after_create :send_alert
  
  def send_alert
    thumbwar.challenges.each do |challenge|
      challenge.user.alerts.create!(alertable: self.thumbwar, body: (self.side == 'opponents' ? "Someone sided with you!" : "Someone sided against you!"  ))
      challenge.challenger.alerts.create!(alertable: self.thumbwar, body: (self.side == 'challenger' ? "Someone sided with you!" : "Someone sided against you!"  ))
    end
  end
  handle_asynchronously :send_alert
end
