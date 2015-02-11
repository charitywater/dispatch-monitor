class AddErrorCodeAndDeviceIdToSensorRegistrationResponse < ActiveRecord::Migration
  def change
    add_column :sensor_registration_responses, :error_code, :string
  end
end
