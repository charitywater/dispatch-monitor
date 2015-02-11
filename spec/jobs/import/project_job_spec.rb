require 'spec_helper'

module Import
  describe ProjectJob do
    specify do
      expect(ProjectJob.queue).to eq :import
    end

    describe '.perform' do
      let(:results) { { created: [1] } }
      let(:importer) { double(:importer) }
      let(:job_data) { double(:job_data, id: 'job_data_id') }

      let(:bulk_import_notifications) { double(:bulk_import_notifications) }
      let(:subscription) { double(:subscription, account_id: 'the-account') }

      before do
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue)
        allow(RemoteMonitoring::WaziImporting::Importer).to receive(:new)
          .and_return(importer)
        allow(EmailSubscription).to receive(:bulk_import_notifications)
          .and_return(bulk_import_notifications)
        allow(bulk_import_notifications).to receive(:find_each)
          .and_yield(subscription)

        allow(JobData).to receive(:create).with(
          data: {
            results: {created: [1]},
            recipient_id: subscription.account_id
          }
        ).and_return(job_data)
        allow(importer).to receive(:import) { results }
      end

      it 'starts the project import from wazi' do
        ProjectJob.perform(
          grant_deployment_code: ['AAA.BBB.Q5.00.000', 'AAA.BBB.Q5.00.001'],
          deployment_code: ['AAA.BBB.Q5.00.000.001', 'AAA.BBB.Q5.00.000.002'],
        )

        expect(importer).to have_received(:import).with(
          grant_deployment_code: ['AAA.BBB.Q5.00.000', 'AAA.BBB.Q5.00.001'],
          deployment_code: ['AAA.BBB.Q5.00.000.001', 'AAA.BBB.Q5.00.000.002'],
        )
      end

      it 'enqueues a mail job' do
        ProjectJob.perform(
          grant_deployment_code: ['AAA.BBB.Q5.00.000', 'AAA.BBB.Q5.00.001'],
          deployment_code: ['AAA.BBB.Q5.00.000.001', 'AAA.BBB.Q5.00.000.002'],
        )

        expect(RemoteMonitoring::JobQueue).to have_received(:enqueue)
          .with(Email::Import::ProjectResultJob, 'job_data_id')
      end
    end
  end
end
