class CreateSurveyResponses < ActiveRecord::Migration
  def change
    create_table :survey_responses do |t|
      t.integer :fs_survey_id, null: false
      t.integer :fs_response_id, null: false
      t.date :submission_date, null: false
      t.belongs_to :project, index: true, null: false
      t.json :response, null: false
      t.timestamps
    end
  end
end
