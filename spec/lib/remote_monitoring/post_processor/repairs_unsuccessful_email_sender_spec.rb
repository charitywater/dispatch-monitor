require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe RepairsUnsuccessfulEmailSender do
      let(:repairs_unsuccessful_email_sender) { RepairsUnsuccessfulEmailSender.new }

      before do
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue)
      end

      describe '#process' do
        let(:policy) do
          double(
            :policy,
            send_repairs_unsuccessful_email?: send_repairs_unsuccessful_email?,
            survey_response: survey_response,
          )
        end

        let(:survey_response) do
          double(
            :survey_response,
            id: 3,
            project_id: 4,
          )
        end

        context 'repairs unsuccessful email should be sent' do
          let(:send_repairs_unsuccessful_email?) { true }

          it 'enqueues the Email::RepairsUnsuccessfulJob' do
            repairs_unsuccessful_email_sender.process(policy)

            expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
              Email::RepairsUnsuccessfulJob,
              3
            )
          end
        end

        context 'repairs unsuccessful email should not be sent' do
          let(:send_repairs_unsuccessful_email?) { false }

          specify do
            repairs_unsuccessful_email_sender.process(policy)

            expect(RemoteMonitoring::JobQueue).not_to have_received(:enqueue)
          end
        end
      end
    end
  end
end
