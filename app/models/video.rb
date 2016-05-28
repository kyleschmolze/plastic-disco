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
end
