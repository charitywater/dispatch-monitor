require 'spec_helper'

module RemoteMonitoring
  module SurveyImporting
    describe Remover do
      let(:client) { double(:client) }
      let(:remover) { Remover.new(client) }

      before do
        allow(client).to receive(:survey_response)
      end

      describe '#remove_deleted' do
        let(:activity) { double(:activity, destroy: nil, data: data) }
        let(:deleted_activity) { double(:deleted_activity, destroy: nil, data: deleted_data) }

        let(:survey_response) { double(:survey_response, fs_survey_id: 123, fs_response_id: 54321, destroy: nil) }
        let(:deleted_survey_response) { double(:deleted_survey_response, fs_survey_id: 123, fs_response_id: 98765, destroy: nil) }

        let(:data) { { fs_survey_id: 123, fs_response_id: 54321 } }
        let(:deleted_data) { { fs_survey_id: 123, fs_response_id: 98765 } }

        let(:osr_activities) { double(:osr_activities) }
        let(:survey_activities) { double(:survey_activities) }
        let(:response_activities) { double(:response_activities) }

        before do
          allow(SurveyResponse).to receive(:find_each).and_yield(survey_response).and_yield(deleted_survey_response)

          allow(Activity).to receive(:observation_survey_received) { osr_activities }
          allow(osr_activities).to receive(:by_fs_survey_id).with(123) { survey_activities }
          allow(survey_activities).to receive(:by_fs_response_id).with(98765) { response_activities }
          allow(response_activities).to receive(:destroy_all)

          allow(client).to receive(:survey_response).with(data) { true }
          allow(client).to receive(:survey_response).with(deleted_data) { false }

          allow(SurveyResponse).to receive(:find_by).with(deleted_data) { deleted_survey_response }
        end

        it 'looks up the existing observation_survey_received activities in FS' do
          remover.remove_deleted

          expect(client).to have_received(:survey_response).with(data)
          expect(client).to have_received(:survey_response).with(deleted_data)
        end

        it 'destroys the removed survey responses' do
          remover.remove_deleted

          expect(survey_response).not_to have_received(:destroy)
          expect(deleted_survey_response).to have_received(:destroy)
        end

        it 'destroys the corresponding activities' do
          remover.remove_deleted

          expect(response_activities).to have_received(:destroy_all)
        end
      end
    end
  end
end
