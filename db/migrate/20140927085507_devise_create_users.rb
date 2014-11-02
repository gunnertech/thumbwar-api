class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :encrypted_password, null: false, default: ""
      t.string :facebook_token
      t.string :first_name
      t.integer :inviter_id
      t.string :last_name
      t.string :mobile
      t.boolean :public, default: true
      t.boolean :publish_to_facebook
      t.boolean :publish_to_twitter
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean :sms_notifications, default: true
      t.string :token
      t.string :twitter_token
      t.string :username, null: false, default: ""

      t.timestamps
    end
    
    add_index :users, :inviter_id
    add_index :users, :mobile
    add_index :users, :reset_password_token, unique: true
    add_index :users, :token, unique: true
    add_index :users, :username
  end
end
