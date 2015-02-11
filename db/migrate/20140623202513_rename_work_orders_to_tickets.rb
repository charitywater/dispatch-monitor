class RenameWorkOrdersToTickets < ActiveRecord::Migration
  def change
    rename_table :work_orders, :tickets
  end
end
