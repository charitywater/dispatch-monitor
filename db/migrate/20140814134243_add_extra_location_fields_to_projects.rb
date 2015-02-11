class AddExtraLocationFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :state, :string
    add_column :projects, :sub_district, :string
    add_column :projects, :system_name, :string
    add_column :projects, :water_point_name, :string
  end
end
