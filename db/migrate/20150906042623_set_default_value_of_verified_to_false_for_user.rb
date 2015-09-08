class SetDefaultValueOfVerifiedToFalseForUser < ActiveRecord::Migration
  def change
    change_column_default :users, :verified, false
  end
end
