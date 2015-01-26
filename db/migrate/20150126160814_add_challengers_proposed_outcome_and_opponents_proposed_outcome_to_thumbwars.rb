class AddChallengersProposedOutcomeAndOpponentsProposedOutcomeToThumbwars < ActiveRecord::Migration
  def change
    add_column :thumbwars, :challengers_proposed_outcome, :string
    add_column :thumbwars, :opponents_proposed_outcome, :string
  end
end
