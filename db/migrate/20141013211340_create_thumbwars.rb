class CreateThumbwars < ActiveRecord::Migration
  def change
    create_table :thumbwars do |t|
      t.boolean :accepted
      t.integer :challenger_id, null: false
      t.text :body, null: false
      t.datetime :expires_at
      t.boolean :public, default: true
      t.string :wager
      t.integer :winner_id

      t.timestamps
    end
    
    add_index :thumbwars, :challenger_id
    add_index :thumbwars, :winner_id
  end
end
