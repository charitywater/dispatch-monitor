require 'spec_helper'

module Import
  describe MaintenanceReportsJob do
    describe '#queue' do
      specify do
        expect(Import::MaintenanceReportsJob.queue).to eq :import
      end
    end

    describe '.perform' do
      let(:results) { double(:results) }
      let(:survey_type1) { double(:survey_type1) }
      let(:survey_type2) { double(:survey_type2) }

      let(:survey_types) { [survey_type1, survey_type2] }
      let(:survey_importer) { double(:survey_importer, import: results) }

      let(:bulk_import_notifications) { double(:bulk_import_notifications) }
      let(:subscription) { double(:subscription, account_id: 5) }

      let(:job_data) { double(:job_data, id: 'job_data_id') }

      before do
        allow(RemoteMonitoring::SurveyImporting::MaintenanceReportsImporter)
          .to receive(:new) { survey_importer }
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue)

        allow(EmailSubscription).to receive(:bulk_import_notifications)
          .and_return(bulk_import_notifications)
        allow(bulk_import_notifications).to receive(:find_each)
          .and_yield(subscription)
        allow(JobData).to receive(:create)
          .with(data: { results: [results, results], recipient_id: 5 })
          .and_return(job_data)
      end

      it 'starts the import of the survey' do
        Import::MaintenanceReportsJob.perform(survey_types)

        expect(survey_importer).to have_received(:import).with(survey_type1)
        expect(survey_importer).to have_received(:import).with(survey_type2)
      end

      it 'enqueues the survey response result email' do
        Import::MaintenanceReportsJob.perform(survey_types)

        expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
          Email::Import::MaintenanceReportsJob,
          'job_data_id'
        )
      end
    end
  end
end
