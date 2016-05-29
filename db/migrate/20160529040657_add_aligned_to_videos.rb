class AddAlignedToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :aligned, :boolean, default: false
  end
end
