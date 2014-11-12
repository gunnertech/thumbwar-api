class Device < ActiveRecord::Base
  belongs_to :user
  
  validates_uniqueness_of :token, scope: :device_type
end
