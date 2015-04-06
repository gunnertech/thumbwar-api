json.(evidence_photo, :id, :thumbwar_id, :user_id)

json.photo do |photo|
  photo.has_default_photo evidence_photo.has_default_photo
  photo.url evidence_photo.photo.url
  photo.large_url evidence_photo.photo.large.url
end