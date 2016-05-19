class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :user_id
      t.string :google_id
      t.string :name
      t.string :mime_type
      t.string :thumbnail
      t.datetime :starts_at
      t.integer :duration
      t.datetime :ends_at

      t.timestamps null: false
    end
    add_index :videos, :user_id
    add_index :videos, :google_id
    add_index :videos, :starts_at
    add_index :videos, :ends_at
  end
end
