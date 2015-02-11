class AddUptimeToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :uptime, :integer
  end
end
