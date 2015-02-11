class ChangeIndexOnWeeklyLogs < ActiveRecord::Migration
  def up
    remove_index :weekly_logs, column: [:red_flag, :unit_id, :week]
    add_index :weekly_logs, :red_flag, order: { red_flag: :desc }
  end

  def down
    remove_index :weekly_logs, :red_flag
    add_index :weekly_logs, [:red_flag, :unit_id, :week], unique: true
  end
end
