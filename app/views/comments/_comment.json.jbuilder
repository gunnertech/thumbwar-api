json.(comment, :id, :body)

json.photo do |photo|
  photo.url comment.photo.url
end

json.user do
  json.partial! "users/user", user: comment.user
end