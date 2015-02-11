require 'spec_helper'

module Email
  module Import
    describe SourceObservationsJob do
      specify do
        expect(Email::Import::SourceObservationsJob.queue).to eq :email
      end

      describe '.perform' do
        let(:data_id) { double(:data_id) }
        let(:email) { double(:email, deliver: true) }
        let(:data) { double(:data) }
        let(:job_data) { double(:job_data, data: data, destroy: true) }

        before do
          allow(::Import::SourceObservationMailer).to receive(:results) { email }
          allow(JobData).to receive(:find).with(data_id) { job_data }
        end

        it 'delivers the email' do
          Email::Import::SourceObservationsJob.perform(data_id)

          expect(::Import::SourceObservationMailer).to have_received(:results).with(data)
          expect(email).to have_received(:deliver)
        end

        it 'destroys its JobData' do
          Email::Import::SourceObservationsJob.perform(data_id)

          expect(job_data).to have_received(:destroy)
        end
      end
    end
  end
end
