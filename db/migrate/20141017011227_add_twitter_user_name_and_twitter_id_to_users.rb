class AddTwitterUserNameAndTwitterIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_username, :string
    add_column :users, :twitter_id, :integer, limit: 8
  end
end
