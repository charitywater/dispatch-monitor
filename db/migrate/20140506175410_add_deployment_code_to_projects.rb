class AddDeploymentCodeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :deployment_code, :string, index: true, null: false
  end
end
