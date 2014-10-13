json.(thumbwar, :id, :description, :expires_in, :status)

json.challengee do
  json.partial! "users/user", user: resource.challengee
end

json.challenger do
  json.partial! "users/user", user: resource.challenger
end

json.watchers do
  json.array! resource.watchers, partial: "users/user", as: :user
end

json.comments do
  json.array! resource.comments, partial: "comments/comment", as: :comment
end