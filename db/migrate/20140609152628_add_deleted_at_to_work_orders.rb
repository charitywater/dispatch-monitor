class AddDeletedAtToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :deleted_at, :datetime
  end
end
