class Device < ActiveRecord::Base
  attr_accessible :user_id, :token, :device_type
  belongs_to :user
  
  validates_uniqueness_of :token, scope: :device_type
end
