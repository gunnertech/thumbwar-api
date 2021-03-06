class Following < ActiveRecord::Base
  attr_accessible :followee_id, :follower_id
  
  belongs_to :followee, class_name: "User"
  belongs_to :follower, class_name: "User"
  
  validates :followee_id, presence: true
  validates :follower_id, presence: true
  validates_uniqueness_of :follower_id, scope: :followee_id
end