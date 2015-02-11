class AddDaysForDailyAverageLitersToSensors < ActiveRecord::Migration
  def change
    rename_column :sensors, :daily_average, :daily_average_liters
    add_column :sensors, :days_for_daily_average_liters, :integer
  end
end
