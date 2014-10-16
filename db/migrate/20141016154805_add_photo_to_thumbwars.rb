class AddPhotoToThumbwars < ActiveRecord::Migration
  def change
    add_column :thumbwars, :photo, :string
  end
end
