class AddImeiToSensor < ActiveRecord::Migration
  def change
    add_column :sensors, :imei, :string
  end
end
