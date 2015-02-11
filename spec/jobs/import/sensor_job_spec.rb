require 'spec_helper'

module Import
  describe SensorJob do
    specify do
      expect(SensorJob.queue).to eq :import
    end

    describe '.perform' do
      let(:data) { double(:data) }
      let(:importer) { double(:importer, import: true) }
      let(:job_data) { double(:job_data, id: 5, data: data) }

      before do
        allow(JobData).to receive(:find).with(5) { job_data }
        allow(RemoteMonitoring::SensorImporting::Importer)
          .to receive(:new) { importer }
      end

      it 'calls the importer with the data' do
        SensorJob.perform(5)

        expect(importer).to have_received(:import).with(data)
      end
    end
  end
end
