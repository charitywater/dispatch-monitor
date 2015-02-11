require 'spec_helper'

describe CollectionPresenter do
  let(:items) do
    [
      double(:item),
      double(:item),
      double(:item),
    ]
  end
  let(:presenter) { CollectionPresenter.new(items, ProjectPresenter) }

  describe '#each' do
    it 'returns a item presenter for each item in the collection' do
      expect(presenter.count).to eq 3
      expect(presenter.all? { |p| p.is_a?(ProjectPresenter) }).to be true
    end
  end
end
