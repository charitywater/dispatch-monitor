require 'spec_helper'
include SunspotMatchers

describe ProjectsController do
  let(:account) { build(:account, :admin) }

  before do
    stub_logged_in(account)

    allow(controller).to receive(:authorize)
  end

  describe '#index' do
    let(:filter_form) { double(:filter_form) }

    before do
      allow(ProjectList).to receive(:new).and_call_original
      allow(FilterForm).to receive(:new) { filter_form }

      get :index
    end

    it 'renders the "index" template' do
      expect(response).to render_template :index
    end

    it 'assigns the projects' do
      expect(assigns(:projects)).to be_a ProjectList
    end

    it 'sends the filter form to the project list' do
      expect(ProjectList).to have_received(:new).with(filter_form)
    end
  end

  describe '#search' do
    before do
      allow(CollectionPresenter).to receive(:new)

      get :search, deployment_code: "ET.GOH.Q2.13.144.008"
    end

    it 'renders the "search" template' do
      expect(response).to render_template :search
    end

    it 'searches for the deployment code' do
      expect(Sunspot.session).to have_search_params(:keywords, "ET.GOH.Q2.13.144.008")
    end
  end

  describe '#show' do
    it 'redirects to the map' do
      get :show, id: 123

      expect(response).to redirect_to map_project_path('123')
    end
  end

  describe '#edit' do
    let(:project) { build(:project, id: 6) }

    before do
      allow(Project).to receive(:find).with('6') { project }

      get :edit, id: 6
    end

    it 'authorizes the action' do
      expect(controller).to have_received(:authorize).with(project, :update?)
    end

    it 'renders the "edit" template' do
      expect(response).to render_template :edit
    end

    it 'assigns the project' do
      expect(assigns(:project)).to eq project
      expect(assigns(:project)).to be_a ProjectPresenter
    end
  end

  describe '#update' do
    let(:project) { build(:project, id: 6) }

    before do
      allow(Project).to receive(:find).with('6') { project }
      allow(project).to receive(:update) { valid? }

      patch :update, id: 6, project: {
        community_name: ' Fancy Community  ',
        deployment_code: 'DEP',
        contact_phone_numbers: {
          '0' => '',
          '1' => '+1 234 567 8900 ',
        }
      }
    end

    context 'if the update is valid' do
      let(:valid?) { true }

      it 'authorizes the action' do
        expect(controller).to have_received(:authorize).with(project, :update?)
      end

      it 'updates the project' do
        expect(project).to have_received(:update).with(
          'community_name' => 'Fancy Community',
          'contact_phone_numbers' => ['+1 234 567 8900']
        )
      end

      it 'redirects to the project index' do
        expect(response).to redirect_to projects_path
      end

      it 'sets the success flash' do
        expect(flash[:success]).to be
      end
    end

    context 'if the update is invalid' do
      let(:valid?) { false }

      it 'authorizes the action' do
        expect(controller).to have_received(:authorize).with(project, :update?)
      end

      it 'renders the "edit" template' do
        expect(response).to render_template :edit
      end

      it 'assigns the project' do
        expect(assigns(:project)).to eq project
        expect(assigns(:project)).to be_a ProjectPresenter
      end

      it 'sets the alert flash' do
        expect(flash.now[:alert]).to be
      end
    end
  end

  describe '#destroy' do
    let(:project) { build :project, id: 5 }

    before do
      allow(Project).to receive(:find).with('5') { project }
      allow(project).to receive(:destroy)
    end

    it 'authorizes the action' do
      delete :destroy, id: 5

      expect(controller).to have_received(:authorize).with(project, :destroy?)
    end

    it 'destroys the project' do
      delete :destroy, id: 5

      expect(project).to have_received(:destroy)
    end

    it 'redirects to the project list' do
      delete :destroy, id: 5

      expect(response).to redirect_to projects_path
    end

    it 'sets the flash' do
      delete :destroy, id: 5

      expect(flash[:success]).to be
    end
  end
end
