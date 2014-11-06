json.array!(@challenges) do |challenge|
  json.extract! challenge, :id, :user_id, :thumbwar_id, :status, :challenger_id
  json.url challenge_url(challenge, format: :json)
end
