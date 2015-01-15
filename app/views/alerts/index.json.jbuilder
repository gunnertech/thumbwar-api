json.result_count 1 
json.alerts do
  json.array! collection, partial: "alerts/alert", as: :alert
end