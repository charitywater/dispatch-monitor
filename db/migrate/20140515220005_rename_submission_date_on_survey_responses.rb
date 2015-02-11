class RenameSubmissionDateOnSurveyResponses < ActiveRecord::Migration
  def up
    change_column :survey_responses, :submission_date, :datetime
    rename_column :survey_responses, :submission_date, :submitted_at
  end

  def down
    rename_column :survey_responses, :submitted_at, :submission_date
    change_column :survey_responses, :submission_date, :date
  end
end
