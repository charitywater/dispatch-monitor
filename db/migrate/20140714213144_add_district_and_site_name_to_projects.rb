class AddDistrictAndSiteNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :district, :string
    add_column :projects, :site_name, :string
  end
end
