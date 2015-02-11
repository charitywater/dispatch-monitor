require 'spec_helper'

module Email
  module Import
    describe ProjectResultJob do
      specify do
        expect(ProjectResultJob.queue).to eq :email
      end

      describe '.perform' do
        let(:data_id) { double(:data_id) }
        let(:email) { double(:email, deliver: true) }
        let(:data) { double(:data) }
        let(:job_data) { double(:job_data, data: data, destroy: true) }

        before do
          allow(JobData).to receive(:find).with(data_id) { job_data }
          allow(::Import::ProjectMailer).to receive(:results) { email }
        end

        it 'delivers the email' do
          ProjectResultJob.perform(data_id)

          expect(::Import::ProjectMailer).to have_received(:results).with(data)
          expect(email).to have_received(:deliver)
        end

        it 'destroys its JobData' do
          ProjectResultJob.perform(data_id)

          expect(job_data).to have_received(:destroy)
        end
      end
    end
  end
end
