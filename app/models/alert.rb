class Alert < ActiveRecord::Base
  attr_accessible :alertable, :alertable_type, :alertable_id, :body, :read, :user_id
  
  belongs_to :alertable, polymorphic: true
  belongs_to :user
  
  validates :alertable_type, presence: true
  validates :alertable_id, presence: true
  validates :user_id, presence: true
end
