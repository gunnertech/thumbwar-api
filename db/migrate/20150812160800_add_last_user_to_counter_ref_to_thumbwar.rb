class AddLastUserToCounterRefToThumbwar < ActiveRecord::Migration
  def change
    add_reference :thumbwars, :challenger_has_seen_popup, index: true, foreign_key: true
  end
end

