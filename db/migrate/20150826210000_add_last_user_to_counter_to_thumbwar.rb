class AddLastUserToCounterRefToThumbwar < ActiveRecord::Migration
  def change
    add_column :thumbwars, :last_user_to_counter, :integer
  end
end

