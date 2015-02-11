class PreventNullFieldsOnActivities < ActiveRecord::Migration
  def change
    change_table :activities do |t|
      t.change :name, :string, null: false
      t.change :date, :date, null: false
      t.change :project_id, :integer, null: false
    end
  end
end
