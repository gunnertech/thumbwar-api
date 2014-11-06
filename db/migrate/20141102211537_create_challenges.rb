class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :thumbwar, index: true, null: false
      t.string :status, null: false, default: "pending"
      t.string :outcome
      t.belongs_to :challenger, index: true, null: false

      t.timestamps
    end
  end
end
