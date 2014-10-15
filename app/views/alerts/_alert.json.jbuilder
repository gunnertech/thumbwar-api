json.(alert, :id, :body, :alertable_type)

json.alertable do
  if alert.alertable.is_a? User
    json.partial! "users/user", user: alert.alertable
  elsif alert.alertable.is_a? Thumbwar
    json.partial! "thumbwars/thumbwar", thumbwar: alert.alertable
  end
end