class AddSurveyTypeToSurveyResponses < ActiveRecord::Migration
  def change
    add_column :survey_responses, :survey_type, :string
    add_index :survey_responses, :survey_type
  end
end
