class SetDefaultValueOfSmsNotificationsToFalseForUser < ActiveRecord::Migration
  def change
    change_column_default :users, :sms_notifications, false
  end
end
