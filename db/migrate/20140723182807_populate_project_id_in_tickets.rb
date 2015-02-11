class PopulateProjectIdInTickets < ActiveRecord::Migration
  class Ticket < ActiveRecord::Base
    belongs_to :survey_response
  end

  def up
    reset_column_information

    Ticket.find_each do |t|
      t.update(project_id: t.survey_response.project_id)
    end
  end

  def down
    reset_column_information

    Ticket.update_all(project_id: nil)
  end

  private

  def reset_column_information
    Ticket.reset_column_information
  end
end
