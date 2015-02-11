class AddSurveyTypeToSensorRegistrationResponses < ActiveRecord::Migration
  def change
    add_column :sensor_registration_responses, :survey_type, :string
    add_index :sensor_registration_responses, :survey_type
  end
end