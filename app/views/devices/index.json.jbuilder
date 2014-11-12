json.array!(@devices) do |device|
  json.extract! device, :id, :user_id, :token, :type
  json.url device_url(device, format: :json)
end
