class AddSubmittedAtToSensorRegistrationResponses < ActiveRecord::Migration
  def change
    add_column :sensor_registration_responses, :submitted_at, :datetime
  end
end