class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.belongs_to :alertable, polymorphic: true, null: false
      t.integer :user_id, null: false
      t.text :body, null: false
      t.boolean :read, default: false

      t.timestamps
    end
    
    add_index :alerts, [:alertable_id, :alertable_type]
    add_index :alerts, :user_id
  end
end
