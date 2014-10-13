class Watching < ActiveRecord::Base
  attr_accessible :thumbwar_id, :user_id
  
  belongs_to :thumbwar
  belongs_to :user
  
  validates :thumbwar_id, presence: true
  validates :user_id, presence: true
end