class AddVideoCountToEvents < ActiveRecord::Migration
  def change
    add_column :events, :video_count, :integer
  end
end
