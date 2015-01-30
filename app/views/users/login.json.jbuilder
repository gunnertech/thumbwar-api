json.partial! "users/user", user: resource
json.(resource, :token)

json.devices do
 json.array! user.resource, partial: "devices/device", as: :device
end