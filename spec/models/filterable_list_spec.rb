require 'spec_helper'

describe FilterableList do
  class TestPresenter < SimpleDelegator
  end

  let(:filter_form) { double(:filter_form) }

  let(:filter_1) { double(:filter_1) }
  let(:filter_2) { double(:filter_2) }
  let(:filters) { [filter_1, filter_2] }

  let(:result_1) { double(:result_1) }
  let(:result_2) { double(:result_2) }
  let(:source) { double(:source) }

  let(:list) { FilterableList.new(filter_form) }

  before do
    allow(list).to receive(:presenter) { TestPresenter }
    allow(list).to receive(:source) { source }
    allow(list).to receive(:filters) { filters }

    allow(filter_1).to receive(:result).with(source) { result_1 }
    allow(filter_2).to receive(:result).with(result_1) { [result_2] }
  end

  describe '#items' do
    it 'returns presented items' do
      expect(list.items.first).to be_a TestPresenter
    end

    it 'combines the specified filters' do
      expect(list.items).to eq [result_2]
    end
  end
end
