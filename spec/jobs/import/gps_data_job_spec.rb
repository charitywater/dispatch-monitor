require 'spec_helper'

module Import
  describe GpsDataJob do
    describe '.queue' do
      specify do
        expect(GpsDataJob.queue).to eq :import
      end
    end

    describe '.perform' do
      let(:importer) { double(:importer, import: true) }
      let(:xml) { double(:xml) }

      before do
        allow(RemoteMonitoring::GpsImporting::Importer).to receive(:new) { importer }
      end

      it 'triggers the import' do
        GpsDataJob.perform(xml)

        expect(importer).to have_received(:import).with(xml)
      end
    end
  end
end
