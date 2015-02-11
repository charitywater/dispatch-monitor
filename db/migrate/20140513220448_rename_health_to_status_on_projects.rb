class RenameHealthToStatusOnProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :health, :status
  end
end
