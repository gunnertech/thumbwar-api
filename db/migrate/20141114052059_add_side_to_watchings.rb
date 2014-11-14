class AddSideToWatchings < ActiveRecord::Migration
  def change
    add_column :watchings, :side, :string
  end
end
