class ChangeDecimalFieldsToStringOnProjects < ActiveRecord::Migration
  def up
    change_column :projects, :cost_actual, :string
    change_column :projects, :inventory_cost, :string
  end

  def down
    change_column :projects, :cost_actual, :decimal, precision: 8, scale: 2
    change_column :projects, :inventory_cost, :decimal, precision: 8, scale: 2
  end
end
