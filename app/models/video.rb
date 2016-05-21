class Video < ActiveRecord::Base

  belongs_to :user

  validates :user, presence: true
  validates :google_id, presence: true

  def to_param
    google_id
  end

  def events
    Event.where('(starts_at > ? AND starts_at < ?) OR (ends_at > ? AND ends_at < ?)', starts_at, ends_at, starts_at, ends_at)
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
end
