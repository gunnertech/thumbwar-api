json.thumbwars do
  json.array! collection, partial: "thumbwars/thumbwar", as: :thumbwar
end