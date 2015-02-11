require 'spec_helper'

describe ProjectList do
  let(:filter_form) { 
    double(:filter_form, 
      page: 123, 
      status: 'the-status', 
      program: program,
      sort_column: "deployment_code",
      sort_direction: "desc"
    ) 
  }
  let(:list) { ProjectList.new(filter_form) }
  let(:program) { double(:program, id: 44, projects: projects) }
  let(:projects) { double(:projects, includes: projects_with_country) }
  let(:projects_with_country) { double(:projects_with_country) }

  let(:by_status_query) { double(:by_status_query) }
  let(:ordered_query) { double(:ordered_query) }
  let(:paginated_query) { double(:paginated_query) }

  before do
    allow(ByStatusQuery).to receive(:new).with('the-status') { by_status_query }
    allow(OrderedQuery).to receive(:new).with('deployment_code desc') { ordered_query }
    allow(PaginatedQuery).to receive(:new).with(123) { paginated_query }
  end

  it 'is a filterable list' do
    expect(list).to be_a FilterableList
  end

  it 'configures the source' do
    expect(list.source).to eq projects_with_country
  end

  it 'includes the country' do
    list.source

    expect(projects).to have_received(:includes).with(:country)
  end

  it 'configures the presenter' do
    expect(list.presenter).to eq ProjectPresenter
  end

  it 'configures the filters' do
    expect(list.filters.length).to eq 3
    expect(list.filters).to include by_status_query
    expect(list.filters).to include ordered_query
    expect(list.filters).to include paginated_query
  end
end
