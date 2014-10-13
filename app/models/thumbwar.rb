class Thumbwar < ActiveRecord::Base
  acts_as_commentable
  alias_attribute :comments, :comment_threads
  
  attr_accessible :challengee_id, :challenger_id, :description, :expires_in, :status, :wager
  
  belongs_to :challengee, class_name: "User", foreign_key: "challengee_id"
  belongs_to :challenger, class_name: "User", foreign_key: "challenger_id"
  
  has_many :watchings
  has_many :watchers, through: :watchings, source: :user
  
  validates :challengee_id, presence: true
  validates :challenger_id, presence: true
  validates :description, presence: true
  
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
end
