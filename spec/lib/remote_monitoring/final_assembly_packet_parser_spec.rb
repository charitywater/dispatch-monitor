require 'spec_helper'

module RemoteMonitoring
  describe FinalAssemblyPacketParser do
    let(:sensor) { double(:sensor) }
    let(:final_assembly_packet) do
      {
        "deviceId" => "1394900463516",
        "ts" => 1422990056746,
        "imei" => "013949004635168",
        "rssi" => 48,
        "signalStrength" => 100,
        "values" => {
          "finalAssembly" => {
            "month" => 10,
            "day" => 25,
            "year" => 5152,
            "hour" => 2,
            "minute" => 25,
            "second" => 28,
            "pm" => 0,
            "fixed" => 0
          }
        }
      }
    end

    let(:time_difference) do
      {
        "days" => "65",
        "hours" => "10",
        "minutes" => "23"
      }
    end

    describe '#calculate_time_difference' do
      it 'calculates the time difference correctly' do
        parser = RemoteMonitoring::FinalAssemblyPacketParser.new(final_assembly_packet)

        expect(parser.calculate_time_difference).to eq time_difference
      end
    end

    describe '#build_payload' do
      it 'builds the payload for the gmt update correctly' do
        parser = RemoteMonitoring::FinalAssemblyPacketParser.new(final_assembly_packet)

        expect(parser.build_payload["data"]).to eq "AQAjEABl"
      end
    end
  end
end