class AddSensorToActivities < ActiveRecord::Migration
  def change
    add_reference :activities, :sensor, index: true
  end
end
