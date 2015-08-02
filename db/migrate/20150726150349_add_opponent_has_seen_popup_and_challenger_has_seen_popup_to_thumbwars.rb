class AddOpponentHasSeenPopupAndChallengerHasSeenPopupToThumbwars < ActiveRecord::Migration
  def change
    add_column :thumbwars, :opponent_has_seen_popup, :boolean, default: false
    add_column :thumbwars, :challenger_has_seen_popup, :boolean, default: false
  end
end

