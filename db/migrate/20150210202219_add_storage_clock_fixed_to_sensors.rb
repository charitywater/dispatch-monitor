class AddStorageClockFixedToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :storage_clock_fixed, :boolean, default: false
  end
end
