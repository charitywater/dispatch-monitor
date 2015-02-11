require 'spec_helper'

module Sensors
  describe ReceiveController do
    describe '#create' do
      let(:sensor) { double(:sensor) }
      let(:data) { { deviceId: 8, imei: "12345" }.to_json }
      let(:job_data) { double(:job_data, id: 7) }

      before do
        allow(::Sensor).to receive(:find_or_create_by).with(imei: "012345") { sensor }
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue)
        allow(JobData).to receive(:create) { job_data }
      end

      it 'responds with 200' do
        post :create, data, format: :json

        expect(response).to be_success
      end

      it 'enqueues the Import::SensorJob' do
        post :create, data, format: :json

        expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
          Import::SensorJob,
          job_data.id
        )
      end
    end
  end
end
