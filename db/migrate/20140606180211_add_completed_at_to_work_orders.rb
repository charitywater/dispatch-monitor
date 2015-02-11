class AddCompletedAtToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :completed_at, :datetime
  end
end
