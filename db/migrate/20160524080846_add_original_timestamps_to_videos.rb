class AddOriginalTimestampsToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :original_starts_at, :datetime
    add_column :videos, :original_ends_at, :datetime
  end
end
