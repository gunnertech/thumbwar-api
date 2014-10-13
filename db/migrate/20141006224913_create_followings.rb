class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.integer :followee_id, null: false
      t.integer :follower_id, null: false
      
      t.timestamps
    end
    
    add_index :followings, :followee_id
    add_index :followings, :follower_id
  end
end
