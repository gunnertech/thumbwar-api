class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :encrypted_password, null: false, default: ""
      t.string :first_name
      t.string :last_name
      t.string :mobile, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.string :token
      t.string :username, null: false

      t.timestamps
    end
    
    add_index :users, :mobile, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :token, unique: true
    add_index :users, :username, unique: true
  end
end
