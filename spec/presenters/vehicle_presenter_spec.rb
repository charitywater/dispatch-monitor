require 'spec_helper'

describe VehiclePresenter do
  let!(:vehicle) { create(:vehicle) }
  let(:presenter) { VehiclePresenter.new(vehicle) }

  describe '#vehicle_type' do
    it 'titleizes the vehicle type' do
      expect(presenter.vehicle_type).to eq vehicle.vehicle_type.titleize
    end
  end

  describe '#program' do
    context 'it has a program' do
      before do
        rest = create(:partner, name: "Relief Society of Tigray")
        ethiopia = create(:country, name: "Ethiopia")
        rest_ethiopia = create(:program, country: ethiopia, partner: rest)
        vehicle.program = rest_ethiopia
      end

      specify do
        expect(presenter.program).to eq 'Relief Society of Tigray - Ethiopia'
      end
    end

    context 'it does not have a program' do
      before do
        vehicle.program = nil
      end

      specify do
        expect(presenter.program).to eq 'N/A'
      end
    end
  end
end
