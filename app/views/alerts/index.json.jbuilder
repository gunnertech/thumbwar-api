json.result_count @result_count
json.last_seen_id @last_seen_id 
json.alerts do
  json.array! collection, partial: "alerts/alert", as: :alert
end