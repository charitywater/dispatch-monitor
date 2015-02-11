class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.integer :device_id, null: false
      t.belongs_to :project, index: true, null: false
      t.timestamps
    end

    add_index :sensors, :device_id
  end
end
