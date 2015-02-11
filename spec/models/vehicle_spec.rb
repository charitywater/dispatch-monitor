require 'spec_helper'

describe Vehicle do
  let(:vehicle) { create(:vehicle, esn: "0-1234567") }

  describe 'associations' do
    specify do
      expect(vehicle).to have_many(:gps_messages)
    end

    specify do
      expect(vehicle).to belong_to(:program)
    end
  end

  describe 'validations' do
    specify do
      expect(vehicle).to validate_presence_of(:esn)
      expect(vehicle).to validate_uniqueness_of(:esn)
    end
  end

  context 'latest gps message functionality' do
    before do
      @bike = create(:vehicle, esn: "0-1234567", vehicle_type: "bike")
      @transmission_1 = create(:gps_message, transmitted_at: Time.zone.now - 3.days, vehicle: @bike)
      @transmission_2 = create(:gps_message, transmitted_at: Time.zone.now - 2.days, vehicle: @bike)
      @transmission_3 = create(:gps_message, transmitted_at: Time.zone.now.beginning_of_day, vehicle: @bike)
    end

    describe '#latest_transmission_time' do
      it 'returns the most recent GpsMessage time' do
        expect(@bike.latest_transmission_time).to eq @transmission_3.transmitted_at
      end
    end

    describe '#latest_transmission_latitude' do
      it 'returns the most recent GpsMessage latitude' do
        expect(@bike.latest_transmission_latitude).to eq @transmission_3.latitude
      end
    end

    describe '#latest_transmission_longitude' do
      it 'returns the most recent GpsMessage longitude' do
        expect(@bike.latest_transmission_longitude).to eq @transmission_3.longitude
      end
    end
  end
end