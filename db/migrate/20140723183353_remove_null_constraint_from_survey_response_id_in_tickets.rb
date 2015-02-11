class RemoveNullConstraintFromSurveyResponseIdInTickets < ActiveRecord::Migration
  def up
    change_column :tickets, :survey_response_id, :integer, null: true
  end

  def down
    # If you have nulls, you take care of it.
    change_column :tickets, :survey_response_id, :integer, null: false
  end
end
