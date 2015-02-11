require 'spec_helper'

describe DashboardController do
  let(:account) { build(:account, :admin) }
  let(:filter_form) { double(:filter_form) }
  before { stub_logged_in(account) }

  describe '#show' do
    before do
      allow(Dashboard).to receive(:new).and_call_original
      allow(DashboardFilterForm).to receive(:new).with(current_account: account) { filter_form }

      get :show
    end

    it 'renders the "show" template' do
      expect(response).to render_template :show
    end

    it 'assigns the dashboard' do
      expect(assigns(:dashboard)).to be_a Dashboard
    end

    it 'sends a filter form to the dashboard' do
      expect(Dashboard).to have_received(:new).with(filter_form)
    end
  end
end
