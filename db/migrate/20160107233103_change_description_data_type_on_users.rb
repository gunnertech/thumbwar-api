class ChangeDescriptionDataTypeOnUsers < ActiveRecord::Migration
  def up
      change_column :users, :facebook_token, :text, :limit => nil
    end

    def down
      change_column :users, :facebook_token, :string
    end
end
