class EvidencePhoto < ActiveRecord::Base
  mount_uploader :photo, PhotoUploader
  belongs_to :user
  belongs_to :thumbwar
  
  attr_accessible :user, :user_id, :thumbwar, :thumbwar_id, :photo, :remote_photo_url
  
  def has_default_photo
    !photo.present?
  end
end
