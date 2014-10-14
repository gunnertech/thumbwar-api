class AddPhotoToComments < ActiveRecord::Migration
  def change
    add_column :comments, :photo, :string
  end
end
