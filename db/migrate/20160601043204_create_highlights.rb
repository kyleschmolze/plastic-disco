class CreateHighlights < ActiveRecord::Migration
  def change
    create_table :highlights do |t|
      t.integer :video_id
      t.integer :offset
      t.integer :duration
      t.string :title

      t.timestamps null: false
    end

    add_index :highlights, :video_id
  end
end
