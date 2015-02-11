require 'spec_helper'

describe VehiclesController do
  let(:account) { double(:account) }

  before do
    stub_logged_in account
    allow(controller).to receive(:authorize)
  end

  describe '#index' do
    let(:vehicle_list) { double(:vehicle_list) }
    let(:filter_form) { double(:filter_form) }

    before do
      allow(FilterForm).to receive(:new).with('page' => '2', current_account: account) { filter_form }
      allow(VehicleList).to receive(:new).with(filter_form) { vehicle_list }
    end

    specify do
      get :index, filters: { page: 2 }

      expect(response).to be_success
      expect(response).to render_template :index
    end

    it 'assigns the vehicle list' do
      get :index, filters: { page: 2 }

      expect(assigns(:vehicles)).to eq vehicle_list
    end
  end

  describe '#new' do
    it 'renders the "new" template' do
      get :new

      expect(response).to render_template :new
    end
  end

  describe '#create' do
    let(:program) { build(:program, id: 8) }
    let(:vehicle) do
      double(
        :vehicle,
        save: valid,
        esn: "0-1234567",
        vehicle_type: 'bike'
      )
    end

    before do
      allow(Vehicle).to receive(:new) { vehicle }
    end

    context 'when the vehicle is valid' do
      let(:valid) { true }

      # it 'authorizes the action' do
      #   post :create, sensor_project: { device_id: 111, deployment_code: 'AA.AAA.Q4.44.444.444' }

      #   expect(controller).to have_received(:authorize).with(anything, :manage?)
      # end

      it 'redirects to the vehicles index' do
        post :create, vehicle: { esn: "0-1234567", vehicle_type: 'bike', program_id: program.id }

        expect(response).to redirect_to vehicles_path
      end

      it 'sets the success flash message' do
        post :create, vehicle: { esn: "0-1234567", vehicle_type: 'bike', program_id: program.id }

        expect(flash[:success]).to include "0-1234567"
        expect(flash[:success]).to include "bike"
      end

      it 'creates a new vehicle' do
        post :create, vehicle: { esn: '0-1234567', vehicle_type: 'bike', program_id: program.id }

        expect(Vehicle).to have_received(:new).with(
          'esn' => '0-1234567',
          'vehicle_type' => 'bike',
          'program_id' => program.id.to_s #because the hash in vehicle_params for some reason always treats this as a string
        )
      end
    end

    context 'when the vehicle is invalid' do
      let(:valid) { false }

      before do
        allow(vehicle).to receive(:errors) { double(:errors, full_messages: %w(Hi there)) }
      end

      it 'renders the "new" template' do
        post :create, vehicle: { esn: "0-1234567", vehicle_type: 'bike', program_id: program.id }

        expect(response).to render_template :new
      end
    end
  end

  describe '#edit' do
    let(:vehicle) { double(:vehicle) }

    before do
      allow(Vehicle).to receive(:find).with('3') { account }

      get :edit, id: 3
    end

    it 'renders the "edit" template' do
      expect(response).to render_template :edit
    end

    # it 'authorizes the action' do
    #   expect(controller).to have_received(:authorize).with(anything, :manage?)
    # end
  end

  describe '#update' do
    let(:vehicle) { double(:vehicle, update: valid, esn: '0-1234567', vehicle_type: 'bike', program_id: '122') }
    let(:valid) { true }

    before do
      allow(Vehicle).to receive(:find).with('3') { vehicle }
    end

    it 'redirects to index' do
      patch :update, id: 3, vehicle: { :esn => '0-1234567', :vehicle_type => 'rig', :program_id => '123' }

      expect(response).to redirect_to vehicles_path
    end

    it 'shows a flash success message' do
      patch :update, id: 3, vehicle: { esn: '0-1234567', vehicle_type: 'rig', program_id: '123' }

      expect(flash[:success]).to include '0-1234567'
    end

    it 'updates the vehicle' do
      patch :update, id: 3, vehicle: { esn: '0-1234567', vehicle_type: 'rig', program_id: '123' }

      expect(vehicle).to have_received(:update).with(
        'esn' => '0-1234567',
        'vehicle_type' => 'rig',
        'program_id' => '123',
      )
    end
  end
end