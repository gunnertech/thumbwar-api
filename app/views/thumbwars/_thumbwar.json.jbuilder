json.(thumbwar, :id, :body, :expires_at, :url, :wager, :minutes_remaining,
:created_at, :has_default_photo, :status, :public, :comments_count,
:opponents_proposed_outcome, :challengers_proposed_outcome,
:opponent_has_seen_popup, :challenger_has_seen_popup)

json.challenger do
  json.partial! "users/user", user: thumbwar.challenger
end

json.evidence_photos do
  json.array! thumbwar.evidence_photos, partial: "evidence_photos/evidence_photo", as: :evidence_photo
end

json.watchings do
  json.array! thumbwar.watchings, partial: "watchings/watching", as: :watching
end

json.challenges do
  json.array! thumbwar.challenges, partial: "challenges/challenge", as: :challenge
end

json.comments do
  json.array! thumbwar.comments, partial: "comments/comment", as: :comment
end

json.photo do |photo|
  photo.url thumbwar.photo.url
  photo.large_url thumbwar.photo.large.url
end
