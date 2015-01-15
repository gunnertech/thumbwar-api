json.(watching, :id, :side, :created_at)

json.user do
  json.partial! "users/user", user: watching.user
end