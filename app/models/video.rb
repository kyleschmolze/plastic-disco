class Video < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :events

  validates :user, presence: true
  validates :google_id, presence: true

  before_create :copy_original_timestamps

  VIDEO_OFFSET = 3.minutes + 9.seconds

  
  def tag_events
    starting_events = Event.where('starts_at >= ? AND starts_at <= ?', starts_at, ends_at)
    ending_events = Event.where('ends_at >= ? AND ends_at <= ?', starts_at, ends_at)
    surrounding_events = Event.where('starts_at <= ? AND ends_at >= ?', starts_at, ends_at)
    events.delete_all
    self.events = (starting_events + ending_events + surrounding_events).uniq
  end

  def offset!
    self.starts_at = original_starts_at - VIDEO_OFFSET
    self.ends_at = original_ends_at - VIDEO_OFFSET
    self.save
  end

  def copy_original_timestamps
    self.original_starts_at = starts_at
    self.original_ends_at = ends_at
  end

  def self.copy(file, user)
    duration = file.api_file.videoMediaMetadata.durationMillis rescue nil

    # assume that if duration is nil, it's not a video
    return if duration.blank?

    starts_at = file.api_file.createdDate
    ends_at = starts_at + (duration.seconds / 1000)

    Video.create! google_id: file.id,
                  user: user,
                  width: file.api_file.videoMediaMetadata.width,
                  height: file.api_file.videoMediaMetadata.height,
                  thumbnail: file.api_file.thumbnailLink,
                  mime_type: file.mime_type,
                  starts_at: starts_at,
                  ends_at: ends_at,
                  duration: duration,
                  name: file.title
  end

  def self.get_youtube_ids
    # TODO store channel_id in user model
    api_key = 'AIzaSyC7ObkpQdx8VNYXn33xkW88GlTsrOxEDpQ'
    youtube_channel_id = 'UCjCcPCvxpSsvHNmgC3SNUZQ'
    url = "https://www.googleapis.com/youtube/v3/search?key=#{api_key}&channelId=#{youtube_channel_id}&part=snippet,id&order=date&maxResults=10"
    response = HTTParty.get url
    json = JSON.parse response.body

    seen_titles = []
    matched_titles = []

    loop do
      for vid in json['items']
        title = vid['snippet']['title'] rescue nil
        seen_titles << title
        youtube_id = vid['id']['videoId'] rescue nil
        description = vid['snippet']['description'] rescue nil
        thumbnail = vid['snippet']['thumbnails']['high']['url'] rescue nil
        existing_video = Video.find_by_name(title)
        next unless existing_video
        existing_video.update_column :thumbnail, thumbnail if thumbnail
        existing_video.update_column :youtube_id, youtube_id if youtube_id
        matched_titles << title
      end

      nextPageToken = json['nextPageToken']
      break unless nextPageToken.present?
      response = HTTParty.get "#{url}&pageToken=#{nextPageToken}"
      json = JSON.parse response.body
    end

    puts "All seen titles: #{seen_titles.join(', ')}"
    puts "All matched titles: #{matched_titles.join(', ')}"
    puts "Youtube-only titles: #{(seen_titles - matched_titles).join(', ')}"
    puts "Drive-only titles: #{(Video.pluck(:name) - seen_titles).join(', ')}"
  end
end
