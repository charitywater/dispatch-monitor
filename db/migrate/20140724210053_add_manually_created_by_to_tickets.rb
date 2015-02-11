class AddManuallyCreatedByToTickets < ActiveRecord::Migration
  def change
    add_reference :tickets, :manually_created_by, index: true
  end
end
