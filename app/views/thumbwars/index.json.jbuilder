json.thumbwars do
  json.total collection.count
  json.array! collection, partial: "thumbwars/thumbwar", as: :thumbwar
end