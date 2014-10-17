class AddPublishToTwitterToThumbwars < ActiveRecord::Migration
  def change
    add_column :thumbwars, :publish_to_twitter, :boolean, default: false
  end
end
