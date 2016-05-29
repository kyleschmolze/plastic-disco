class AddHiddenToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :hidden, :boolean, default: false
  end
end
