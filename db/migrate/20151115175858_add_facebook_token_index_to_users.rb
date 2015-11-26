class AddFacebookTokenIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :facebook_token, unique: true 
  end
end
