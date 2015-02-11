require 'spec_helper'

describe TicketList do
  let(:filter_form) { double(:filter_form, page: 123, status: 'the-status', program: program) }
  let(:list) { TicketList.new(filter_form) }

  let(:eager_loaded_tickets) { double(:eager_loaded_tickets) }
  let(:tickets) { double(:tickets) }
  let(:program) { double(:program, id: 44, tickets: tickets) }

  let(:non_deleted_query) { double(:non_deleted_query) }
  let(:by_status_query) { double(:by_status_query) }
  let(:ordered_query) { double(:ordered_query) }
  let(:paginated_query) { double(:paginated_query) }

  before do
    allow(tickets).to receive(:includes).with(:project) { eager_loaded_tickets }

    allow(Tickets::NonDeletedQuery).to receive(:new) { non_deleted_query }
    allow(ByStatusQuery).to receive(:new).with('the-status') { by_status_query }
    allow(Tickets::OrderedQuery).to receive(:new) { ordered_query }
    allow(PaginatedQuery).to receive(:new).with(123) { paginated_query }
  end

  it 'is a filterable list' do
    expect(list).to be_a FilterableList
  end

  it 'configures the source' do
    expect(list.source).to eq eager_loaded_tickets
  end

  it 'configures the presenter' do
    expect(list.presenter).to eq TicketPresenter
  end

  it 'configures the filters' do
    expect(list.filters.length).to eq 4
    expect(list.filters).to include non_deleted_query
    expect(list.filters).to include by_status_query
    expect(list.filters).to include ordered_query
    expect(list.filters).to include paginated_query
  end
end
