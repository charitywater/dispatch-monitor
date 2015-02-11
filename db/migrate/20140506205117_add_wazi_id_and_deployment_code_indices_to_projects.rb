class AddWaziIdAndDeploymentCodeIndicesToProjects < ActiveRecord::Migration
  def change
    add_index :projects, :wazi_id, unique: true
    add_index :projects, :deployment_code
  end
end
