class AddHeightAndWidthToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :height, :integer
    add_column :videos, :width, :integer
  end
end
