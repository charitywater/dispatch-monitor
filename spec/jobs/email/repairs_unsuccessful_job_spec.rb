require 'spec_helper'

module Email
  describe RepairsUnsuccessfulJob do
    describe '.queue' do
      specify do
        expect(RepairsUnsuccessfulJob.queue).to eq :email
      end
    end

    describe '.perform' do
      let(:survey_response_id) { 4 }
      let(:email) { double(:email, deliver: true) }

      before do
        allow(ProjectMailer).to receive(:repairs_unsuccessful) { email }
      end

      it 'sends the repairs_unsuccessful project email' do
        RepairsUnsuccessfulJob.perform(survey_response_id)

        expect(ProjectMailer).to have_received(:repairs_unsuccessful).with(survey_response_id)
        expect(email).to have_received(:deliver)
      end
    end
  end
end
