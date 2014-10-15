class AddVerificationCodeAndVerifiedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :verification_code, :string
    add_column :users, :verified, :boolean, default: false
  end
end
