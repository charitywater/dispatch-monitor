require 'spec_helper'

module Map
  describe Map::ProjectsController do
    let(:account) { build(:account, :admin) }
    before { stub_logged_in(account) }

    describe '#show' do
      let(:project) { double(:project, id: 5) }
      let(:filter_form) { double(:filter_form) }
      let(:map) { double(:map) }

      before do
        allow(FilterForm).to receive(:new) { filter_form }
        allow(Project).to receive(:find).with(project.id.to_s) { project }
        allow(ProjectMap).to receive(:new).with(filter_form, project) { map }
        allow(controller).to receive(:authorize)
      end

      it 'authorizes the action' do
        get :show, id: project.id

        expect(controller).to have_received(:authorize).with(project, :show?)
      end

      it 'renders the "show" template' do
        get :show, id: project.id

        expect(response).to render_template :show
      end

      it 'parses the filters' do
        get :show, id: project.id, filters: { status: 'inactive' }

        expect(FilterForm).to have_received(:new).with('status' => 'inactive', current_account: account)
      end

      it 'assigns the map' do
        get :show, id: project.id

        expect(assigns(:map)).to eq map
      end

      context 'json' do
        let(:project) { build(:project, id: 123) }

        it 'responds with the project as a json object' do
          get :show, id: project.id, format: :json

          json = JSON.parse(response.body)
          expect(json['id']).to eq(project.id)
        end
      end
    end
  end
end
