class Event < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :videos

  validates :name, presence: true
  validates :kind, presence: true
  validates :starts_at, presence: true
end
