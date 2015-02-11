require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe SensorStorageClockUpdater do
      let(:sensor_storage_clock_updater) { SensorStorageClockUpdater.new }

      describe '#build_payload' do
        it 'returns the correct payload with a whole number offset' do
          offset = 5
          result = sensor_storage_clock_updater.build_payload(offset)

          expect(result["data"]).to eq "AgAAAAU="
        end

        it 'returns the correct payload with a fractional offset' do
          offset = 5.75
          result = sensor_storage_clock_updater.build_payload(offset)

          expect(result["data"]).to eq "AgAALQU="
        end
      end
    end
  end
end