require 'spec_helper'

describe SensorPresenter do
  let!(:sensor) { Sensor.new }
  let(:presenter) { SensorPresenter.new(sensor) }

  describe '#daily_average' do
    context 'when the sensor has daily logs' do
      before do
        allow(sensor).to receive(:daily_average_liters) { 5.123 }
      end

      it 'rounds to the nearest integer' do
        expect(presenter.daily_average).to eq 5
      end
    end

    context 'when the sensor does not have daily logs' do
      before do
        allow(sensor).to receive(:daily_average_liters) { nil }
      end

      it 'returns nil' do
        expect(presenter.daily_average).to be_nil
      end
    end
  end
end
