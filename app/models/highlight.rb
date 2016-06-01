class Highlight < ActiveRecord::Base
  belongs_to :video

  validates :video, presence: true
  validates :title, presence: true
  validates :offset, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
end
