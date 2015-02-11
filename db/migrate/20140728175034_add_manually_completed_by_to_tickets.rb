class AddManuallyCompletedByToTickets < ActiveRecord::Migration
  def change
    add_reference :tickets, :manually_completed_by, index: true
  end
end
