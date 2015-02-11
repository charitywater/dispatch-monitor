class CreateApplicationSettings < ActiveRecord::Migration
  def change
    create_table :application_settings do |t|
      t.boolean :sensors_affect_project_status, null: false, default: false
      t.timestamps
    end
  end
end
