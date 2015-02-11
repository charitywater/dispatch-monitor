class RenameVehicleTypeField < ActiveRecord::Migration
  def change
    rename_column :vehicles, :type, :vehicle_type
  end
end
