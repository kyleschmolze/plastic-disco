class DropVideoCountFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :video_count
  end
end
