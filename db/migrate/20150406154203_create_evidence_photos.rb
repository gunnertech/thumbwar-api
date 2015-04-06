class CreateEvidencePhotos < ActiveRecord::Migration
  def change
    create_table :evidence_photos do |t|
      t.belongs_to :user, index: true
      t.belongs_to :thumbwar, index: true
      t.string :photo

      t.timestamps
    end
  end
end
