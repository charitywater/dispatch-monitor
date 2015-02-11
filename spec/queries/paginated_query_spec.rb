require 'spec_helper'

describe PaginatedQuery do
  describe '#result' do
    let(:query) { PaginatedQuery.new(page) }
    let(:page) { double(:page) }
    let(:paginated) { double(:paginated) }
    let(:relation) { double(:relation) }

    before do
      allow(relation).to receive(:page).with(page) { paginated }
    end

    it 'calls `page`' do
      expect(query.result(relation)).to eq paginated
    end
  end
end
