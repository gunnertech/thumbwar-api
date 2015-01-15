class Watching < ActiveRecord::Base
  attr_accessible :thumbwar_id, :user_id, :side
  
  belongs_to :thumbwar
  belongs_to :user
  
  validates :thumbwar_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :thumbwar_id, scope: :user_id
end
