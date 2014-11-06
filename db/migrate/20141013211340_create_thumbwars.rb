class CreateThumbwars < ActiveRecord::Migration
  def change
    create_table :thumbwars do |t|
      t.integer :challenger_id, null: false
      t.text :body, null: false
      t.datetime :expires_at
      t.boolean :public, default: true
      t.string :wager
      t.string :status, default: 'in_progress', null: false

      t.timestamps
    end
    
    add_index :thumbwars, :challenger_id
  end
end
