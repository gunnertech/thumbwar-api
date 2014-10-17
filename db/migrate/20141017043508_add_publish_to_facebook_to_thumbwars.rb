class AddPublishToFacebookToThumbwars < ActiveRecord::Migration
  def change
    add_column :thumbwars, :publish_to_facebook, :boolean, default: false
  end
end
