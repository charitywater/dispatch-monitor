require 'spec_helper'

module Search
  describe ProjectList do
    let(:filter_form) { double(:filter_form, program: program) }
    let(:list) { Search::ProjectList.new(filter_form, [1, 2, 3, 4]) }
    let(:projects) { double(:projects) }
    let(:program) { double(:program, id: 44, projects: projects) }
    let(:filtered_projects) { double(:filtered_projects) }

    before do
      allow(projects).to receive(:within_bounds).with(1, 2, 3, 4) { filtered_projects }
    end

    it 'is a filterable list' do
      expect(list).to be_a FilterableList
    end

    it 'configures the source' do
      expect(list.source).to eq filtered_projects
    end

    it 'configures the presenter' do
      expect(list.presenter).to eq Search::ProjectPresenter
    end

    it 'configures the filters' do
      expect(list.filters).to eq []
    end
  end
end
