class AddEsnToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :esn, :string, null: false
  end
end
