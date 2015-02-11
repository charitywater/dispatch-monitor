require 'spec_helper'

module Email
  module Import
    describe MaintenanceReportsJob do
      specify do
        expect(MaintenanceReportsJob.queue).to eq :email
      end

      describe '.perform' do
        let(:data_id) { double(:data_id) }
        let(:email) { double(:email, deliver: true) }
        let(:job_data) { double(:job_data, data: data, destroy: true) }
        let(:data) { double(:data) }

        before do
          allow(JobData).to receive(:find).with(data_id) { job_data }
          allow(::Import::MaintenanceReportMailer).to receive(:results) { email }
        end

        it 'delivers the email' do
          MaintenanceReportsJob.perform(data_id)

          expect(::Import::MaintenanceReportMailer).to have_received(:results).with(data)
          expect(email).to have_received(:deliver)
        end

        it 'destroys its JobData' do
          MaintenanceReportsJob.perform(data_id)

          expect(job_data).to have_received(:destroy)
        end
      end
    end
  end
end
