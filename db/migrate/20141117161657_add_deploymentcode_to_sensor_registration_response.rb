class AddDeploymentcodeToSensorRegistrationResponse < ActiveRecord::Migration
  def change
    add_column :sensor_registration_responses, :deployment_code, :string
  end
end
