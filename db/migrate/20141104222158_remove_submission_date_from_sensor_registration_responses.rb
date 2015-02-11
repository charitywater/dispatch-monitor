class RemoveSubmissionDateFromSensorRegistrationResponses < ActiveRecord::Migration
  def up
    remove_column :sensor_registration_responses, :submission_date
  end

  def down
    add_column :sensor_registration_responses, :submission_date, :date
  end
end