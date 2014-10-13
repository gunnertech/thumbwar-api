class CreateThumbwars < ActiveRecord::Migration
  def change
    create_table :thumbwars do |t|
      t.boolean :accepted
      t.integer :challengee_id, null: false
      t.integer :challenger_id, null: false
      t.text :description, null: false
      t.integer :expires_in
      t.boolean :public, default: true
      t.string :wager
      t.integer :winner_id

      t.timestamps
    end
    
    add_index :thumbwars, :challengee_id
    add_index :thumbwars, :challenger_id
    add_index :thumbwars, :winner_id
  end
end