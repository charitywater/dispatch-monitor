require 'spec_helper'

describe TicketsController do
  let(:account) { build(:account, :admin) }
  let(:non_deleted_tickets) { double(:non_deleted_tickets) }

  before do
    stub_logged_in(account)
    allow(controller).to receive(:authorize)

    allow(Ticket).to receive(:non_deleted) { non_deleted_tickets }
  end

  describe '#index' do
    let(:tickets) { [double(:ticket)] }
    let(:filter_form) { double(:filter_form) }

    before do
      allow(FilterForm).to receive(:new).with(program_id: '3', current_account: account) { filter_form }
      allow(TicketList).to receive(:new) { tickets }

      get :index, filters: { program_id: 3 }
    end

    it 'renders the "index" template' do
      expect(response).to be_success
      expect(response).to render_template :index
    end

    it 'assigns the tickets' do
      expect(assigns(:tickets)).to eq tickets
    end

    it 'sends the filter form to the ticket list' do
      expect(TicketList).to have_received(:new).with(filter_form)
    end
  end

  describe '#show' do
    let(:ticket) { build(:ticket, id: 5) }

    before do
      allow(non_deleted_tickets).to receive(:find).with('5') { ticket }
    end

    it 'authorizes the action' do
      get :show, id: ticket.id

      expect(controller).to have_received(:authorize).with(ticket, :show?)
    end

    it 'renders the show template' do
      get :show, id: ticket.id

      expect(response).to render_template :show
    end

    it 'assigns the ticket' do
      get :show, id: ticket.id

      expect(assigns(:ticket)).to eq ticket
      expect(assigns(:ticket)).to be_a TicketPresenter
    end
  end

  describe '#new' do
    let(:project) { build(:project, id: 8) }

    before do
      allow(Project).to receive(:find).with('8') { project }
    end

    it 'authorizes the action' do
      get :new, project_id: project.id

      expect(controller).to have_received(:authorize).with(assigns(:ticket), :create?)
    end

    it 'renders the "new" template' do
      get :new, project_id: project.id

      expect(response).to render_template :new
    end

    it 'assigns the ticket with a project' do
      get :new, project_id: project.id

      expect(assigns(:ticket)).to be_a TicketPresenter
      expect(assigns(:ticket).project).to eq project
    end
  end

  describe '#create' do
    let(:project) { build(:project, id: 8) }
    let!(:ticket) { build(:ticket, id: 4) }
    let(:valid) { true }

    before do
      allow(Project).to receive(:find).with('8') { project }
      allow(ManuallyCreatedTicket).to receive(:new) { ticket }
      allow(ticket).to receive(:save) { valid }
    end

    it 'authorizes the action' do
      post :create, project_id: project.id, ticket: { notes: 'notes' }

      expect(controller).to have_received(:authorize).with(ticket, :create?)
    end

    context 'ticket is valid' do
      let(:valid) { true }

      it 'redirects to the ticket' do
        post :create, project_id: project.id, ticket: { notes: 'notes' }

        expect(response).to redirect_to ticket_path(ticket)
      end

      it 'flashes success' do
        post :create, project_id: project.id, ticket: { notes: 'notes' }

        expect(flash[:success]).to include "4"
      end

      it 'creates the ticket with the right params' do
        post :create, project_id: project.id, ticket: { notes: 'notes', extra: 'stuff' }

        expect(ManuallyCreatedTicket).to have_received(:new).with(
          'notes' => 'notes',
          'status' => :in_progress,
          'project' => project,
          'manually_created_by' => account,
        )
      end
    end

    context 'ticket is invalid' do
      let(:valid) { false }

      it 'renders the "new" template' do
        post :create, project_id: project.id, ticket: { notes: 'notes' }

        expect(response).to render_template :new
      end

      it 'assigns the ticket' do
        post :create, project_id: project.id, ticket: { notes: 'notes' }

        expect(assigns(:ticket)).to be_a TicketPresenter
      end

      it 'flashes alert' do
        post :create, project_id: project.id, ticket: { notes: 'notes' }

        expect(flash.now[:alert]).to be
      end
    end
  end

  describe '#complete' do
    let(:ticket) do
      double(
        :ticket,
        update: !complete?,
        community_name: 'Fancy Community',
        deployment_code: 'AA.AAA.Q4.44.444.444',
        project_status: project_status,
        project: double(:project),
        id: 5
      )
    end
    let(:complete?) { double(:complete?) }
    let(:project_status) { 'new_status' }

    before do
      allow(ManuallyCompletedTicket).to receive(:find).with('5') { ticket }
    end

    it 'authorizes the action' do
      patch :complete, id: 5, ticket: { project_status: project_status }

      expect(controller).to have_received(:authorize).with(ticket, :update?)
    end

    context 'ticket can be completed' do
      let(:complete?) { false }

      it 'manually completes the ticket' do
        patch :complete, id: 5, ticket: { project_status: project_status }

        expect(ticket).to have_received(:update).with(
          manually_completed_by: account,
          project_status: 'new_status',
        )
      end

      it 'redirects to the ticket' do
        patch :complete, id: 5, ticket: { project_status: project_status }

        expect(response).to redirect_to ticket_path(ticket)
      end

      it 'flashes success' do
        patch :complete, id: 5, ticket: { project_status: project_status }

        expect(flash[:success]).to include '5'
        expect(flash[:success]).to include 'Fancy Community'
        expect(flash[:success]).to include 'AA.AAA.Q4.44.444.444'
      end
    end

    context 'ticket cannot be completed' do
      let(:complete?) { true }

      it 'responds with 422 UNPROCESSABLE ENTITY' do
        patch :complete, id: 5, ticket: { project_status: project_status }

        expect(response.status).to eq 422
      end

      it 'renders nothing' do
        expect(response.body).to eq ''
      end
    end
  end

  describe '#destroy' do
    let(:ticket) { build(:ticket, id: 5) }

    before do
      allow(non_deleted_tickets).to receive(:find).with('5') { ticket }
      allow(ticket).to receive(:soft_delete)
    end

    it 'authorizes the action' do
      delete :destroy, id: 5

      expect(controller).to have_received(:authorize).with(ticket, :destroy?)
    end

    it 'deletes the ticket' do
      delete :destroy, id: 5

      expect(ticket).to have_received(:soft_delete)
    end

    it 'redirects to the ticket list' do
      delete :destroy, id: 5

      expect(response).to redirect_to(tickets_path)
    end
  end
end
