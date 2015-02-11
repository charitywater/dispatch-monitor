namespace :gps do
  desc 'Seeds the existing GPS units and associates messages'
  task add_units: :environment do |t, args|
    VALID_ESNS = %w(
      1250133
      1247106
      1248964
      1227975
      1227980
      1248779
      1227634
      1248507
      1248985
      1249509
      1223278
      1227997
      1227859
      1231421
      1224448
      1224451
      1224375
      1228859
      1231048
      1226680
      1227749
      1249492
    )

    #create all vehicles
    VALID_ESNS.each do |esn|
      if esn == "1226680" || esn == "1227749"
        p "creating #{esn} - rig"
        Vehicle.create(esn: "0-#{esn}", vehicle_type: "rig") unless Vehicle.where(esn: "0-#{esn}").exists?
      else
        p "creating #{esn} - bike"
        Vehicle.create(esn: "0-#{esn}", vehicle_type: "bike") unless Vehicle.where(esn: "0-#{esn}").exists?
      end
    end

    # associate each gps message with a vehicle
    GpsMessage.all.each do |msg|
      msg.vehicle = Vehicle.where(esn: "0-#{msg.esn}").first
      msg.save
    end
  end
end
