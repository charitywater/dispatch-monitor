class AddProgramToVehicle < ActiveRecord::Migration
  def change
    add_reference :vehicles, :program, index: true
  end
end
