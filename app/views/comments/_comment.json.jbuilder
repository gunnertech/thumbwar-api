json.(comment, :id, :body)

json.user do
  json.partial! "users/user", user: comment.user
end