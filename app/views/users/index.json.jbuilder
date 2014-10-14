json.users do
  json.array! collection, partial: "users/user", as: :user
end