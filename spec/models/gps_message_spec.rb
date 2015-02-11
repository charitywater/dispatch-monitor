require 'spec_helper'

describe GpsMessage do
  let(:gps_message) { GpsMessage.new }

  describe 'associations' do
    specify do
      expect(gps_message).to belong_to(:vehicle)
    end
  end

  describe 'validations' do
    specify do
      expect(gps_message).to validate_presence_of(:esn)
    end

    specify do
      expect(gps_message).to validate_presence_of(:transmitted_at)
    end

    specify do
      expect(gps_message).to validate_presence_of(:payload)
    end
  end
end
