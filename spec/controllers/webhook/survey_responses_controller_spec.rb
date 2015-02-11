require 'spec_helper'

module Webhook
  describe SurveyResponsesController do
    describe '#create' do
      let(:survey_response) { double(:survey_response, save: true) }

      before do
        allow(Webhook::SurveyResponse).to receive(:new).with(
          'survey_type' => 'source_observation_v1',
          'fs_survey_id' => '1',
          'fs_response_id' => '2',
          'webhook' => true,
        ) { survey_response }
      end

      it 'enqueues Import::SourceObservationJob' do
        post :create, fs_survey_id: 1, fs_response_id: 2, survey_type: 'source_observation_v1'

        expect(survey_response).to have_received(:save)
      end

      it 'renders nothing with status 200' do
        post :create, fs_survey_id: 1, fs_response_id: 2, survey_type: 'source_observation_v1'

        expect(response).to be_success
        expect(response.body).to be_blank
      end
    end
  end
end
