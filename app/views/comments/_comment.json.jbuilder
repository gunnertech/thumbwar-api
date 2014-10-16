json.(comment, :id, :body)

if comment.photo.present?
  json.photo do |photo|
    photo.url comment.photo.url
    photo.small_url comment.photo.small.url
    photo.large_url comment.photo.large.url
  end
end

json.user do
  json.partial! "users/user", user: comment.user
end