require 'spec_helper'

module Map
  describe Map::WeeklyLogPresenter do
    let(:weekly_log) { WeeklyLog.new }
    let(:presenter) { Map::WeeklyLogPresenter.new(weekly_log) }

    describe '#as_json' do
      let(:received_at) { Time.zone.now }

      before do
        weekly_log.received_at = received_at
        allow(weekly_log).to receive(:total_liters) { 100 }
      end

      it 'returns the weekly log graph data' do
        json = presenter.as_json

        expect(json[:received_at]).to eq received_at
        expect(json[:total_liters]).to eq 100
      end
    end
  end
end
