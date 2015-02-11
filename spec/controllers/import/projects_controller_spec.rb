require 'spec_helper'

module Import
  describe ProjectsController do
    let(:account) { double(:account) }

    before do
      stub_logged_in(account)
      allow(controller).to receive(:authorize)
    end

    describe '#new' do
      it 'renders the "new" template' do
        get :new
        expect(response).to render_template :new
      end

      it 'assigns a project import' do
        get :new
        expect(assigns(:import_project)).to be
      end

      it 'authorizes the action' do
        get :new
        expect(controller).to have_received(:authorize).with(anything, :manage?)
      end
    end

    describe '#create' do
      before do
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue)
      end

      context 'present import codes' do
        let(:import_codes) { "AA.BBB.Q4.00.000.001\nAA.BBB.Q4.00.000\nAA.BBB.Q4.00.001\nAA.BBB.Q4.00.000.002\n" }

        it 'imports the corresponding projects' do
          post :create, import_project: { import_codes: import_codes }

          expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
            Import::ProjectJob,
            grant_deployment_code: ['AA.BBB.Q4.00.000', 'AA.BBB.Q4.00.001'],
            deployment_code: ['AA.BBB.Q4.00.000.001', 'AA.BBB.Q4.00.000.002'],
          )
        end

        it 'sets the flash info' do
          post :create, import_project: { import_codes: import_codes }

          expect(flash[:info]).to be
        end

        it 'authorizes the action' do
          post :create, import_project: { import_codes: import_codes }

          expect(controller).to have_received(:authorize).with(anything, :manage?)
        end
      end

      context 'blank import codes' do
        it 'renders the "create" template' do
          post :create, import_project: { import_codes: '' }

          expect(flash[:alert]).to eq "Import codes can't be blank"
          expect(response).to render_template :new
        end
      end
    end
  end
end
