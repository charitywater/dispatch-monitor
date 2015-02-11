class AddSubmittedAtToWeeklyLogs < ActiveRecord::Migration
  def change
    add_column :weekly_logs, :submitted_at, :datetime
  end
end
