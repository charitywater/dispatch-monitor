class AddVehicleToGpsMessage < ActiveRecord::Migration
  def change
    add_reference :gps_messages, :vehicle, index: true
  end
end
