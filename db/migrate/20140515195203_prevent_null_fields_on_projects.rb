class PreventNullFieldsOnProjects < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.change :wazi_id, :integer, null: false
      t.change :status, :integer, null: false
      t.change :program_id, :integer, null: false
    end
  end
end
