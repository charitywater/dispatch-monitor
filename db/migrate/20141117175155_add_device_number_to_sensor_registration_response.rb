class AddDeviceNumberToSensorRegistrationResponse < ActiveRecord::Migration
  def change
    add_column :sensor_registration_responses, :device_number, :string
  end
end
