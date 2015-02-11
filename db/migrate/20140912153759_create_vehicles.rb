class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string :type, null: true

      t.timestamps
    end
  end
end
