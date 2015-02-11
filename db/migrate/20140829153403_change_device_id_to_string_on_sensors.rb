class ChangeDeviceIdToStringOnSensors < ActiveRecord::Migration
  def up
    change_column :sensors, :device_id, :string
  end

  def down
    change_column :sensors, :device_id, :integer
  end
end
