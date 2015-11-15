class AddFacebookTokenIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :facebook_token 
  end
end
