class Alert < ActiveRecord::Base
  attr_accessible :alertable, :alertable_type, :alertable_id, :body, :read, :user_id
  
  belongs_to :alertable, polymorphic: true
  belongs_to :user
end
