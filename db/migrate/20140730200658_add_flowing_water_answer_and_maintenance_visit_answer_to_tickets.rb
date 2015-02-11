class AddFlowingWaterAnswerAndMaintenanceVisitAnswerToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :flowing_water_answer, :string
    add_column :tickets, :maintenance_visit_answer, :string
  end
end
