require 'spec_helper'

module RemoteMonitoring
  module SensorImporting
    describe Importer do
      let(:importer) { RemoteMonitoring::SensorImporting::Importer.new(processors) }
      let(:processors) do
        [
          double(:processor1, process: true),
          double(:processor2, process: true),
        ]
      end

      describe '#import' do
        let(:sensor) do
          double(:sensor, weekly_logs: weekly_logs)
        end

        let(:policy) { double(:policy) }
        let(:parser) { double(:parser) }
        let(:final_assembly_parser) { double(:final_assembly_parser) }
        let(:weekly_logs) do
          double(:weekly_logs, create: weekly_log)
        end
        let(:weekly_log) do
          double(
            :weekly_log,
            has_out_of_band_pair?: has_out_of_band_pair?,
          )
        end
        let(:decoded_weekly) { double(:decoded_weekly) }
        # this is the weekly packet that comes from raw_data defined later in the file
        let(:weekly_packet) {
          {
            "values" => {
              "weeklyLog"=>
              {
                "redFlag"=>0,
                "gmtSecond"=>9,
                "gmtMinute"=>54,
                "gmtHour"=>2,
                "gmtDay"=>23,
                "gmtMonth"=>10,
                "gmtYear"=>14,
                "dailyLogs"=> [
                {
                  "liters"=>[2047, 72, 18, 129, 256, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788],
                  "padMax"=>[57231, 57231, 57231, 57231, 57231, 43906],
                  "padMin"=>[45075, 43951, 45816, 48220, 51308, 43757],
                  "padSubmerged"=>[44879, 43770, 45614, 48007, 51066, 1381],
                  "unknowns"=>1371,
                  "redFlag"=>255
                },
                {
                  "liters"=>[2047, 72, 18, 129, 256, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788],
                  "padMax"=>[57231, 57231, 57231, 57231, 57231, 43906],
                  "padMin"=>[45075, 43951, 45816, 48220, 51308, 43757],
                  "padSubmerged"=>[44879, 43770, 45614, 48007, 51066, 1381],
                  "unknowns"=>1371,
                  "redFlag"=>255
                },
                {
                  "liters"=>[2047, 72, 18, 129, 256, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788],
                  "padMax"=>[57231, 57231, 57231, 57231, 57231, 43906],
                  "padMin"=>[45075, 43951, 45816, 48220, 51308, 43757],
                  "padSubmerged"=>[44879, 43770, 45614, 48007, 51066, 1381],
                  "unknowns"=>1371,
                  "redFlag"=>255
                },
                {
                  "liters"=>[2047, 72, 18, 129, 256, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788],
                  "padMax"=>[57231, 57231, 57231, 57231, 57231, 43906],
                  "padMin"=>[45075, 43951, 45816, 48220, 51308, 43757],
                  "padSubmerged"=>[44879, 43770, 45614, 48007, 51066, 1381],
                  "unknowns"=>1371,
                  "redFlag"=>255
                },
                {
                  "liters"=>[2047, 72, 18, 129, 256, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788],
                  "padMax"=>[57231, 57231, 57231, 57231, 57231, 43906],
                  "padMin"=>[45075, 43951, 45816, 48220, 51308, 43757],
                  "padSubmerged"=>[44879, 43770, 45614, 48007, 51066, 1381],
                  "unknowns"=>1371,
                  "redFlag"=>255
                },
                {
                  "liters"=>[2047, 72, 18, 129, 256, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788],
                  "padMax"=>[57231, 57231, 57231, 57231, 57231, 43906],
                  "padMin"=>[45075, 43951, 45816, 48220, 51308, 43757],
                  "padSubmerged"=>[44879, 43770, 45614, 48007, 51066, 1381],
                  "unknowns"=>1371,
                  "redFlag"=>255
                },
                {
                  "liters"=>[2047, 72, 18, 129, 256, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788, 1788],
                  "padMax"=>[57231, 57231, 57231, 57231, 57231, 43906],
                  "padMin"=>[45075, 43951, 45816, 48220, 51308, 43757],
                  "padSubmerged"=>[44879, 43770, 45614, 48007, 51066, 1381],
                  "unknowns"=>1371,
                  "redFlag"=>255
                }]
              }
            }
          }
        }

        let(:has_out_of_band_pair?) { true }
        let(:imei) { "13949004634708" }
        let(:fa_imei) { "13949004634708" }
        let(:data) do
          {
            "deviceId" => "1289600793682",
            "ts" => 1399504535103,
            "imei" => imei,
            "data" => "//8ACVQCIxAUII/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34KrE7Cvq/iyXLxsyO2qT6/6qi6yh7t6x2UFWwVQBVQFVwWJBSUY/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P31ur76+Iq9OyMLw8yP6qp69Aq46y3Lvrx1oFTwVZBVoFWwWIBcoY/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P33Gr+6+dq96ySbxPyAirsK9Jq42y6Lv6x10FVAVWBVwFVwWIBXUZ/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P32Wr/q+Sq9uyO7xSyA2rxq9Qq5qy87v/x2MFWAVQBVQFYAWJBSUa/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P32Or/K+Yq9myO7xZyOaqk68hq2WyxLvix1kFYAVRBVMFXQWIBc4a/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P3xeso7AvrIGz3rz7yISpKK7tqQKxUroAxlMZmRlxGkoaehqBGwAF/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P3yytgrHkrCy0tL0Yyq6koKi8pHern7QBwfFMJU5dT3VPkk8CUXsN////////",
            "values" => {
              "weeklyLog" => {
                "unitID" => 1234,
                "week" => 26,
                "redFlag" => 255,
                "gmtYear" => 14,
                "gmtMonth" => 5,
                "gmtDay" => 4,
                "gmtHour" => 3,
                "gmtMinute" => 2,
                "gmtSecond" => 1,
                "dailyLogs" => [
                  { "liters" => [ 0, 0 ], "unknowns" => 0, },
                  { "liters" => [ 1, 1 ], "unknowns" => 1, },
                ]
              }
            }
          }
        end
        let(:raw_data) do
          {
            "deviceId" => "1289600793682",
            "ts" => 1399504535103,
            "imei" => imei,
            "voltage" => 3807,
            "adc" => 8,
            "rssi" => 72,
            "signalStrength" => 83,
            "data" => "//8ACVQCIxAUII/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34KrE7Cvq/iyXLxsyO2qT6/6qi6yh7t6x2UFWwVQBVQFVwWJBSUY/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P31ur76+Iq9OyMLw8yP6qp69Aq46y3Lvrx1oFTwVZBVoFWwWIBcoY/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P33Gr+6+dq96ySbxPyAirsK9Jq42y6Lv6x10FVAVWBVwFVwWIBXUZ/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P32Wr/q+Sq9uyO7xSyA2rxq9Qq5qy87v/x2MFWAVQBVQFYAWJBSUa/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P32Or/K+Yq9myO7xZyOaqk68hq2WyxLvix1kFYAVRBVMFXQWIBc4a/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P3xeso7AvrIGz3rz7yISpKK7tqQKxUroAxlMZmRlxGkoaehqBGwAF/////4/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P34/fj9+P3yytgrHkrCy0tL0Yyq6koKi8pHern7QBwfFMJU5dT3VPkk8CUXsN////////"
          }
        end
        let(:raw_data_daily) do
          {
            "deviceId" => "1289600793682",
            "ts" => 1399504535103,
            "imei" => imei,
            "voltage" => 3807,
            "adc" => 8,
            "rssi" => 72,
            "signalStrength" => 83,
            "data" => "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA56dZp1Cjo6xStJy9dKbbpseigKuTssK8AAAAAAAAAAAAAAAA//92Ev//"
          }
        end

        let(:final_assembly_packet) do
          {
            "deviceId" => "1394900463516",
            "ts" => 1422990056746,
            "imei" => "013949004635168",
            "rssi" => 48,
            "signalStrength" => 100,
            "values" => {
              "finalAssembly" => {
                "minute" => 0,
                "second" => 28,
                "month" => 10,
                "pm" => 0,
                "year" => 5108,
                "day" => 25,
                "hour" => 2,
                "fixed" => 0
              }
            }
          }
        end

        let(:final_assembly_packet_fixed) do
          {
            "deviceId" => "1394900463516",
            "ts" => 1422990056746,
            "imei" => "013949004635168",
            "rssi" => 48,
            "signalStrength" => 100,
            "values" => {
              "finalAssembly" => {
                "minute" => 0,
                "second" => 28,
                "month" => 10,
                "pm" => 0,
                "year" => 5108,
                "day" => 25,
                "hour" => 2,
                "fixed" => 1
              }
            }
          }
        end

        before do
          allow(SensorDataParser).to receive(:new) { parser }
          allow(parser).to receive(:decode_weekly) { weekly_packet }

          allow(Sensor).to receive(:find_or_create_by).with(imei: "013949004634708") { sensor }
          allow(sensor).to receive(:save)

          allow(FinalAssemblyPacketParser).to receive(:new) { final_assembly_parser }
          allow(final_assembly_parser).to receive(:send_gmt_update)
          
          allow(PostProcessor::SensorPolicy).to receive(:new).with(sensor, weekly_log) { policy }
          allow(sensor).to receive(:imei) { imei }
        end

        context 'final assembly packet received' do
          before do
            @fa_sensor = create(:sensor, imei: "013949004635168", clock_fixed: false)
            allow(Sensor).to receive(:find_or_create_by).with(imei: "013949004635168") { @fa_sensor }
            allow(@fa_sensor).to receive(:save)
          end

          context 'first final assembly packet' do
            it 'creates a new instance of the parser' do
              importer.import(final_assembly_packet)

              expect(FinalAssemblyPacketParser).to have_received(:new)
            end

            it 'sends the gmt update' do
              importer.import(final_assembly_packet)

              expect(final_assembly_parser).to have_received(:send_gmt_update)
            end
          end

          context 'any subsequent final assembly packets' do
            context 'sensor has received a gmt update' do
              before do
                @fa_sensor.clock_fixed = true
                allow(Sensor).to receive(:find_or_create_by).with(imei: "013949004635168") { @fa_sensor }
                allow(@fa_sensor).to receive(:save)
              end

              it 'does not send a gmt update' do
                importer.import(final_assembly_packet_fixed)

                expect(final_assembly_parser).to_not have_received(:send_gmt_update)
              end
            end

            context 'sensor has not received a gmt update' do
              it 'creates a new instance of the parser' do
                importer.import(final_assembly_packet)

                expect(FinalAssemblyPacketParser).to have_received(:new)
              end

              it 'sends the gmt update' do
                importer.import(final_assembly_packet)

                expect(final_assembly_parser).to have_received(:send_gmt_update)
              end
            end
          end
        end

        it 'detects raw sensor data' do
          importer.import(raw_data)

          expect(SensorDataParser).to have_received(:new)
        end

        context 'raw data received' do
          context 'weekly packet' do
            it 'creates the sensor weekly log' do
              importer.import(raw_data)

              expect(weekly_logs).to have_received(:create)
            end
          end

          context 'daily packet' do
            it 'does not create a sensor weekly log' do
              importer.import(raw_data_daily)

              expect(weekly_logs).to_not have_received(:create)
            end

            it 'does not call the post processors' do
              importer.import(raw_data_daily)

              processors.each do |processor|
                expect(processor).not_to have_received(:process)
              end
            end
          end

        end

        it 'creates the sensor weekly log' do
          importer.import(data)

          date = DateTime.new(2014, 5, 7, 23, 15, 35.103)
          start_of_week = Time.utc(2014, 5, 4, 3, 2, 1)

          expect(weekly_logs).to have_received(:create).with(
            red_flag: 255,
            unit_id: 1234,
            week: 26,
            received_at: date,
            week_started_at: start_of_week,
            data: data,
          )
        end

        context 'no out-of-band packet this week' do
          let(:has_out_of_band_pair?) { false }

          it 'calls the post processors with the SensorPolicy' do
            importer.import(data)

            processors.each do |processor|
              expect(processor).to have_received(:process).with(policy)
            end
          end
        end

        context 'out-of-band packet received earlier this week' do
          let(:has_out_of_band_pair?) { true }

          it 'does not call the post processors' do
            importer.import(data)

            processors.each do |processor|
              expect(processor).not_to have_received(:process)
            end
          end
        end
      end
    end
  end
end
