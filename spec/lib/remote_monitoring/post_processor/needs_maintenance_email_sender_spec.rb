require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe NeedsMaintenanceEmailSender do
      let(:needs_maintenance_email_sender) { NeedsMaintenanceEmailSender.new }

      before do
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue)
      end

      describe '#process' do
        let(:policy) do
          double(
            :policy,
            send_needs_maintenance_email?: send_needs_maintenance_email?,
            survey_response: survey_response,
          )
        end

        let(:project) { double(:project) }
        let(:survey_response) do
          double(
            :survey_response,
            id: 3,
            project_id: 4,
            project: project,
          )
        end

        context 'needs maintenance email should be sent' do
          let(:send_needs_maintenance_email?) { true }

          it 'enqueues the ProjectNeedsMaintenance Email Job' do
            needs_maintenance_email_sender.process(policy)

            expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
              Email::ProjectNeedsMaintenanceJob,
              3
            )
          end
        end

        context 'needs maintenance email should not be sent' do
          let(:send_needs_maintenance_email?) { false }

          specify do
            needs_maintenance_email_sender.process(policy)

            expect(RemoteMonitoring::JobQueue).not_to have_received(:enqueue)
          end
        end
      end
    end
  end
end
