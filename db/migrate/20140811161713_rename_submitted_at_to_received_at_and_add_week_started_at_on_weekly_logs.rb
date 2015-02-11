class RenameSubmittedAtToReceivedAtAndAddWeekStartedAtOnWeeklyLogs < ActiveRecord::Migration
  def change
    rename_column :weekly_logs, :submitted_at, :received_at
    add_column :weekly_logs, :week_started_at, :datetime
  end
end
