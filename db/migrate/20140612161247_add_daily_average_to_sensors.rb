class AddDailyAverageToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :daily_average, :float
  end
end
