json.thumbwars do
  json.total @thumbwars.count
  json.array! collection, partial: "thumbwars/thumbwar", as: :thumbwar
end