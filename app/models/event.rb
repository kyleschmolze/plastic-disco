class Event < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :videos

  validates :title, presence: true
  validates :kind, presence: true
  validates :starts_at, presence: true

  validates :title, uniqueness: { scope: [:kind, :starts_at, :ends_at] }
  
  def self.with_query(query)
    words = query.to_s.split.map(&:strip).select(&:present?)
    return Event.all if words.blank?

    matches_word = []
    for word in words
      w = "%#{word}%"
      q = "title ILIKE ? OR kind ILIKE ? "
      q += "OR to_char(starts_at, 'HH12:MI:SS day DD month MM YYYY') LIKE ? "
      q += "OR to_char(starts_at, 'HH12:MI:SS day DD month MM YYYY') LIKE ?"
      matches_word << Event.where(q, w, w, w, w).pluck(:id)
    end
    matches_all_words = matches_word.inject(:&)

    #t.datetime "starts_at"
    #t.datetime "ends_at"
    Event.where(id: matches_all_words)
  end
end
