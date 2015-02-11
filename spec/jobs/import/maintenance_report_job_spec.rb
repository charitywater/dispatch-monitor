require 'spec_helper'

module Import
  describe MaintenanceReportJob do
    describe '.queue' do
      specify do
        expect(MaintenanceReportJob.queue).to eq :import
      end
    end

    describe '.perform' do
      let(:importer) { double(:importer, import: nil) }
      let(:params) { double(:params) }
      let(:survey_importer) { double(:survey_importer) }

      before do
        allow(RemoteMonitoring::SurveyImporting::Webhook::Importer)
          .to receive(:new).with(survey_importer: survey_importer) { importer }

        allow(RemoteMonitoring::SurveyImporting::MaintenanceReportImporter)
          .to receive(:new) { survey_importer }
      end

      it 'imports the maintenance report' do
        MaintenanceReportJob.perform(params)

        expect(importer).to have_received(:import).with(params)
      end
    end
  end
end
