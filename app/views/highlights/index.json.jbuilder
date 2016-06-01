json.array!(@highlights) do |highlight|
  json.extract! highlight, :id, :video_id, :offset, :duration, :title
  json.url highlight_url(highlight, format: :json)
end
