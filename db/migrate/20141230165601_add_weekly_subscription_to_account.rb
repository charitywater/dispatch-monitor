class AddWeeklySubscriptionToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :weekly_subscription, :boolean
  end
end
