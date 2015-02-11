require 'spec_helper'

describe SensorsController do
  let(:account) { double(:account) }

  before do
    stub_logged_in account
    allow(controller).to receive(:authorize)
  end

  describe '#index' do
    let(:sensor_list) { double(:sensor_list) }
    let(:filter_form) { double(:filter_form) }

    before do
      allow(FilterForm).to receive(:new).with('page' => '2', current_account: account) { filter_form }
      allow(SensorList).to receive(:new).with(filter_form) { sensor_list }
    end

    specify do
      get :index, filters: { page: 2 }

      expect(response).to be_success
      expect(response).to render_template :index
    end

    it 'assigns the sensor list' do
      get :index, filters: { page: 2 }

      expect(assigns(:sensors)).to eq sensor_list
    end

    it 'authorizes the action' do
      get :index, filters: { page: 2 }
      expect(controller).to have_received(:authorize).with(anything, :manage?)
    end
  end

  describe '#new' do
    it 'assigns the sensor as a form object' do
      get :new

      expect(assigns(:sensor)).to be_a SensorProject
    end

    it 'renders the "new" template' do
      get :new

      expect(response).to render_template :new
    end

    it 'authorizes the action' do
      get :new
      expect(controller).to have_received(:authorize).with(anything, :manage?)
    end
  end

  describe '#create' do
    let(:sensor_project) do
      double(
        :sensor_project,
        save: valid,
        device_id: 111,
        imei: "01112",
        deployment_code: 'AA.AAA.Q4.44.444.444',
        community_name: 'Fancy Community',
      )
    end

    before do
      allow(SensorProject).to receive(:new) { sensor_project }
    end

    context 'when the sensor project is valid' do
      let(:valid) { true }

      it 'authorizes the action' do
        post :create, sensor_project: { device_id: 111, imei: "01112", deployment_code: 'AA.AAA.Q4.44.444.444' }

        expect(controller).to have_received(:authorize).with(anything, :manage?)
      end

      it 'redirects to the sensors index' do
        post :create, sensor_project: { device_id: 111, imei: "01112", deployment_code: 'AA.AAA.Q4.44.444.444' }

        expect(response).to redirect_to sensors_path
      end

      it 'sets the success flash message' do
        post :create, sensor_project: { device_id: 111, imei: "01112", deployment_code: 'AA.AAA.Q4.44.444.444' }

        expect(flash[:success]).to include '111'
        expect(flash[:success]).to include '01112'
        expect(flash[:success]).to include 'AA.AAA.Q4.44.444.444'
        expect(flash[:success]).to include 'Fancy Community'
      end

      it 'creates a new sensor project' do
        post :create, sensor_project: { device_id: 111, imei: "01112", deployment_code: 'AA.AAA.Q4.44.444.444' }

        expect(SensorProject).to have_received(:new).with(
          'device_id' => '111',
          'imei' => '01112',
          'deployment_code' => 'AA.AAA.Q4.44.444.444',
        )
      end
    end

    context 'when the sensor project is invalid' do
      let(:valid) { false }

      before do
        allow(sensor_project).to receive(:errors) { double(:errors, full_messages: %w(Hi there)) }
      end

      it 'renders the "new" template' do
        post :create, sensor_project: { device_id: 111, imei: "01112", deployment_code: 'AA.AAA.Q4.44.444.444' }

        expect(response).to render_template :new
      end

      it 'assigns the sensor' do
        post :create, sensor_project: { device_id: 111, imei: "01112", deployment_code: 'AA.AAA.Q4.44.444.444' }

        sensor = assigns(:sensor)

        expect(sensor.device_id).to eq 111
        expect(sensor.imei).to eq "01112"
        expect(sensor.deployment_code).to eq 'AA.AAA.Q4.44.444.444'
      end
    end
  end

  describe '#destroy' do
    let(:project) { double(:project) }
    let(:sensor) do
      double(
        :sensor,
        id: 5,
        project: project,
        community_name: 'Fancy Community',
        deployment_code: 'AA.AAA.Q4.44.444.444',
        device_id: 3,
        imei: "035",
        destroy: true,
      )
    end

    before do
      allow(Sensor).to receive(:find).with('5') { sensor }
    end

    it 'authorizes the action' do
      delete :destroy, id: 5
      expect(controller).to have_received(:authorize).with(anything, :manage?)
    end

    it 'redirects to the sensors index' do
      delete :destroy, id: 5

      expect(response).to redirect_to sensors_path
    end

    it 'sets the success flash message' do
      delete :destroy, id: 5

      expect(flash[:success]).to include '3'
      expect(flash[:success]).to include '035'
      expect(flash[:success]).to include 'AA.AAA.Q4.44.444.444'
      expect(flash[:success]).to include 'Fancy Community'
    end

    it 'destroys the sensor' do
      delete :destroy, id: 5

      expect(sensor).to have_received(:destroy)
    end
  end
end
