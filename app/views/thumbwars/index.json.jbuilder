json.total_for_view @total_count
json.total @count
json.thumbwars do
  json.array! collection, partial: "thumbwars/thumbwar", as: :thumbwar
end
