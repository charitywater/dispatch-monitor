class AddClockFixedToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :clock_fixed, :boolean, default: false
  end
end
