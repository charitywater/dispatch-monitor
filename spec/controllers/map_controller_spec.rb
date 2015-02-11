require 'spec_helper'

describe MapController do
  let(:account) { double(:account) }

  before { stub_logged_in account }

  describe '#show' do
    let(:filter_form) { double(:filter_form) }
    let(:map) { double(:map) }

    before do
      allow(FilterForm).to receive(:new) { filter_form }
      allow(ProjectMap).to receive(:new).with(filter_form) { map }
    end

    it 'renders the show template' do
      get :show, filters: { status: 'inactive' }

      expect(response).to render_template :show
    end

    it 'assigns a map' do
      get :show, filters: { status: 'inactive' }

      expect(FilterForm).to have_received(:new).with('status' => 'inactive', current_account: account)
      expect(assigns(:map)).to eq map
    end
  end
end
