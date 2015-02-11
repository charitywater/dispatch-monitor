class AddNullConstraintToProjectIdInTickets < ActiveRecord::Migration
  def up
    change_column :tickets, :project_id, :integer, null: false
  end

  def down
    change_column :tickets, :project_id, :integer, null: true
  end
end
