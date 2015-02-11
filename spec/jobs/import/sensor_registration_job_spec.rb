require 'spec_helper'

module Import
  describe SensorRegistrationJob do
    describe '.queue' do
      specify do
        expect(SensorRegistrationJob.queue).to eq :import
      end
    end

    describe '.perform' do
      let(:params) { double(:params) }
      let(:importer) { double(:importer, import: nil) }
      let(:survey_importer) { double(:survey_importer) }

      before do
        allow(RemoteMonitoring::SurveyImporting::Webhook::Importer)
          .to receive(:new).with(survey_importer: survey_importer) { importer }

        allow(RemoteMonitoring::SurveyImporting::SensorRegistrationImporter)
          .to receive(:new) { survey_importer }
      end

      it 'imports the response using the webhook importer' do
        SensorRegistrationJob.perform(params)

        expect(importer).to have_received(:import).with(params)
      end
    end
  end
end
