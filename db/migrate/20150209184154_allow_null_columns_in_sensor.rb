class AllowNullColumnsInSensor < ActiveRecord::Migration
  def up
    change_column :sensors, :device_id, :string, :null => true
    change_column :sensors, :project_id, :string, :null => true
  end
end
