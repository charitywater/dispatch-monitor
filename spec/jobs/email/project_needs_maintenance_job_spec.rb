require 'spec_helper'

module Email
  describe ProjectNeedsMaintenanceJob do
    describe '.queue' do
      specify do
        expect(ProjectNeedsMaintenanceJob.queue).to eq :email
      end
    end

    describe '.perform' do
      let(:survey_response_id) { 4 }
      let(:email) { double(:email, deliver: true) }

      before do
        allow(ProjectMailer).to receive(:needs_maintenance) { email }
      end

      it 'sends the needs_maintenance project email' do
        ProjectNeedsMaintenanceJob.perform(survey_response_id)

        expect(ProjectMailer).to have_received(:needs_maintenance).with(survey_response_id)
        expect(email).to have_received(:deliver)
      end
    end
  end
end
