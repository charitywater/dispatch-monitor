namespace :gps do
  desc 'Retrieve latest transmissions from all Gps Units'
  task latest_transmissions: :environment do |t, args|
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

    transmissions = []

    VALID_ESNS.each do |esn|
      latest_transmission = GpsMessage.where(esn: esn).order(transmitted_at: :desc).first
      unless latest_transmission.nil?
        new_transmission = {}
        new_transmission["esn"] = latest_transmission.esn
        new_transmission["transmitted_at"] = latest_transmission.transmitted_at.to_datetime.in_time_zone("America/New_York")
        new_transmission["payload"] = latest_transmission.payload
        new_transmission["latitude"] = latest_transmission.latitude
        new_transmission["longitude"] = latest_transmission.longitude
        new_transmission["confidence"] = latest_transmission.confidence

        transmissions.push(new_transmission)
      end
    end

    transmissions.each { |transmission| p transmission }
  end
end
