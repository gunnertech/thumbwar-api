json.partial! "users/user", user: resource
json.(resource, :token)

json.devices do
 json.array! resource.devices, partial: "devices/device", as: :device
end