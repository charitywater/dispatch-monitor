require 'spec_helper'

module Search
  describe ProjectPresenter do
    let(:project) { build(:project, :flowing, id: 3, latitude: 25, longitude: 52) }
    let(:presenter) { Search::ProjectPresenter.new(project) }

    describe '#as_json' do
      it 'returns the essential fields' do
        expect(presenter.as_json).to eq(
          id: 3,
          latitude: 25,
          longitude: 52,
          status: 'flowing'
        )
      end
    end

    describe '#to_json' do
      it 'returns the #as_json result as JSON' do
        expect(presenter.to_json).to eq('{"id":3,"latitude":25.0,"longitude":52.0,"status":"flowing"}')
      end
    end
  end
end
