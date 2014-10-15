class AddUrlToThumbwars < ActiveRecord::Migration
  def change
    add_column :thumbwars, :url, :string
  end
end
