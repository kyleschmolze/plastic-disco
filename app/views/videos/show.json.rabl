object @video

attributes :id, :starts_at, :ends_at, :duration, :youtube_id, :title

node :starts_at_since_epoch do |video|
  video.starts_at.to_i
end

node :ends_at_since_epoch do |video|
  video.ends_at.to_i
end

child :highlights do
  attributes :id, :title, :offset, :duration
end
