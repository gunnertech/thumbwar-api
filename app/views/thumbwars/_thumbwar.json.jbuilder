json.(thumbwar, :id, :body, :expires_at, :status, :accepted, :winner_id, :url, :wager, :minutes_remaining, :created_at, :has_default_photo)

json.challenger do
  json.partial! "users/user", user: thumbwar.challenger
end

json.watchers do
  json.array! thumbwar.watchers, partial: "users/user", as: :user
end

json.comments do
  json.array! thumbwar.comments, partial: "comments/comment", as: :comment
end

json.photo do |photo|
  photo.url thumbwar.photo.url
  photo.large_url thumbwar.photo.large.url
end