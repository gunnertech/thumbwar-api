json.(challenge, :id, :user_id, :thumbwar_id, :status, :challenger_id, :created_at, :updated_at)

json.user do
  json.partial! "users/user", user: challenge.user
end