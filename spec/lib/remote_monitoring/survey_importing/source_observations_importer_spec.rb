require 'spec_helper'

module RemoteMonitoring
  module SurveyImporting
    describe SourceObservationsImporter do
      let(:importer) { SourceObservationsImporter.new(client: client, survey_importer: survey_importer) }
      let(:survey_importer) { double(:survey_importer, import: nil) }
      let(:client) { double(:client, responses: survey_responses) }
      let(:survey_type) { 'source_observation_v1' }
      let(:survey_responses) do
        [
          { '_id' => 11, },
          { '_id' => 12, },
          { '_id' => 13, },
        ]
      end

      describe '#import' do
        let(:survey_response) { SurveyResponse.new }

        let(:new_response) { double(:new_response, fs_survey_id: 1, fs_response_id: 11, deployment_code: 'AA.AAA.Q1.09.111.111') }
        let(:existing_response) { double(:existing_response, fs_survey_id: 1, fs_response_id: 12, deployment_code: 'AA.AAA.Q1.09.111.112') }
        let(:null_response) { double(:null_response, fs_survey_id: 1, fs_response_id: 13, deployment_code: 'AA.AAA.Q1.09.111.113') }

        let(:new_survey_response) { double(:new_survey_response, previous_changes: { id: nil }) }
        let(:existing_survey_response) { double(:existing_survey_response, previous_changes: {}) }

        before do
          allow(FluidSurveys::Structure::SourceObservationV1).to receive(:new).with('_id' => 11) { new_response }
          allow(FluidSurveys::Structure::SourceObservationV1).to receive(:new).with('_id' => 12) { existing_response }
          allow(FluidSurveys::Structure::SourceObservationV1).to receive(:new).with('_id' => 13) { null_response }

          allow(survey_importer).to receive(:import).with(new_response) { new_survey_response }
          allow(survey_importer).to receive(:import).with(existing_response) { existing_survey_response }
          allow(survey_importer).to receive(:import).with(null_response) { nil }
        end

        it 'returns the count of invalid, created and updated survey responses' do
          result = importer.import(survey_type)

          expect(result[:created].count).to eq 1
          expect(result[:updated].count).to eq 1
          expect(result[:invalid].count).to eq 1
        end

        it 'gets the responses for the right survey id' do
          importer.import(survey_type)

          expect(client).to have_received(:responses).with(FluidSurveys::Structure::SourceObservationV1.survey_id)
        end

        it 'returns the survey type' do
          result = importer.import(survey_type)

          expect(result[:survey_type]).to eq survey_type
        end
      end
    end
  end
end
