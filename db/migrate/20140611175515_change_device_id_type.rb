class ChangeDeviceIdType < ActiveRecord::Migration
  def up
    change_column(:sensors, :device_id, :bigint, null: false)
  end

  def down
    change_column(:sensors, :device_id, :integer, null: false)
  end
end
