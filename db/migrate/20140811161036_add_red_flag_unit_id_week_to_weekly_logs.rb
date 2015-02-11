class AddRedFlagUnitIdWeekToWeeklyLogs < ActiveRecord::Migration
  def change
    add_column :weekly_logs, :red_flag, :integer
    add_column :weekly_logs, :unit_id, :integer
    add_column :weekly_logs, :week, :integer

    add_index :weekly_logs, [:red_flag, :unit_id, :week], unique: true
  end
end
