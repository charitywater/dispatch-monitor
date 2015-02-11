class AddWeeklyLogToTickets < ActiveRecord::Migration
  def change
    add_reference :tickets, :weekly_log, index: true
  end
end
