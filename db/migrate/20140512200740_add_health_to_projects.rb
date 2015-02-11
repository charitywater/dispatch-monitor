class AddHealthToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :health, :integer, default: 0
    add_index :projects, :health
  end
end
