class AddLastUserToCounterRefToThumbwar < ActiveRecord::Migration
  def change
    add_reference :thumbwars, :last_user_to_counter, index: true, foreign_key: true
  end
end

