require 'spec_helper'

module Map
  describe Map::TicketsController do
    let(:account) { double(:account) }

    before do
      stub_logged_in(account)
      allow(controller).to receive(:authorize)
    end

    describe '#index' do
      let(:project) { build(:project, :flowing, id: 5) }

      let(:tickets) { double(:tickets) }
      let(:ordered_tickets) { double(:ordered_tickets) }
      let(:tickets_and_accounts) do
        [
          build(:ticket, :overdue),
          build(:ticket, :complete),
        ]
      end
      let(:non_deleted_query) { double(:non_deleted_query) }
      let(:ordered_query) { double(:ordered_query) }

      before do
        allow(Project).to receive(:find).with('5') { project }

        allow(Tickets::NonDeletedQuery).to receive(:new) { non_deleted_query }
        allow(Tickets::OrderedQuery).to receive(:new) { ordered_query }
        allow(account).to receive(:viewer?)

        allow(non_deleted_query).to receive(:result)
          .with(project.tickets) { tickets }
        allow(ordered_query).to receive(:result)
          .with(tickets) { ordered_tickets }
        allow(ordered_tickets).to receive(:includes)
          .with(:manually_created_by, :manually_completed_by) { tickets_and_accounts }
      end

      it 'authorizes the action' do
        get :index, project_id: 5

        expect(controller).to have_received(:authorize).with(project, :show?)
      end

      it 'renders the tickets as json' do
        get :index, project_id: 5

        json = JSON.parse(response.body)
        expect(json['tickets'].map { |t| t['status'] })
          .to eq %w(overdue complete)
      end

      it 'renders project details' do
        get :index, project_id: 5

        json = JSON.parse(response.body)
        expect(json['project_id']).to eq 5
        expect(json['allows_new_ticket']).to eq true
      end
    end
  end
end
