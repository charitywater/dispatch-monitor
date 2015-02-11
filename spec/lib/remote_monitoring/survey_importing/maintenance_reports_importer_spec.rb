require 'spec_helper'

module RemoteMonitoring
  module SurveyImporting
    describe MaintenanceReportsImporter do
      let(:importer) { MaintenanceReportsImporter.new(client: client, survey_importer: survey_importer) }
      let(:client) { double(:client, responses: survey_responses) }
      let(:survey_importer) { double(:survey_importer, import: nil) }
      let(:survey_type) { 'maintenance_report_v02' }
      let(:survey_responses) { [{ '_id' => 11 }] }
      let(:parsed_response) do
        double(
          :parsed_response,
          fs_survey_id: 1,
          fs_response_id: 11,
          deployment_code: 'AA.AAA.Q1.98.111.111',
          repairs_successful?: repairs_successful,
          now_inactive?: now_inactive,
          valid?: valid,
        )
      end
      let(:valid) { true }
      let(:repairs_successful) { true }
      let(:now_inactive) { false }

      describe '#import' do
        let(:import_result) { double(:import_result) }

        before do
          allow(FluidSurveys::Structure::MaintenanceReportV02).to receive(:new).with('_id' => 11) { parsed_response }
          allow(survey_importer).to receive(:import).with(parsed_response, anything) { import_result }
        end

        context 'repairs are successful' do
          let(:valid) { true }
          let(:repairs_successful) { true }

          it 'returns the count' do
            result = importer.import(survey_type)

            expect(result[:complete].count).to eq 1
            expect(result[:incomplete].count).to eq 0
            expect(result[:invalid].count).to eq 0
            expect(result[:inactive].count).to eq 0
          end
        end

        context 'repairs are unsuccessful' do
          let(:valid) { true }
          let(:repairs_successful) { false }

          it 'returns the count' do
            result = importer.import(survey_type)

            expect(result[:complete].count).to eq 0
            expect(result[:incomplete].count).to eq 1
            expect(result[:invalid].count).to eq 0
            expect(result[:inactive].count).to eq 0
          end
        end

        context 'project is inactive' do
          let(:valid) { true }
          let(:repairs_successful) { false }
          let(:now_inactive) { true }

          it 'returns the count' do
            result = importer.import(survey_type)

            expect(result[:complete].count).to eq 0
            expect(result[:incomplete].count).to eq 1
            expect(result[:invalid].count).to eq 0
            expect(result[:inactive].count).to eq 1
          end
        end

        context 'survey response is invalid' do
          let(:valid) { false }

          it 'returns the count' do
            result = importer.import(survey_type)

            expect(result[:complete].count).to eq 0
            expect(result[:incomplete].count).to eq 0
            expect(result[:invalid].count).to eq 1
            expect(result[:inactive].count).to eq 0
          end
        end

        it 'gets the responses for the right survey id' do
          importer.import(survey_type)

          expect(client).to have_received(:responses).with(FluidSurveys::Structure::MaintenanceReportV02.survey_id)
        end

        it 'calls the survey importer' do
          importer.import(survey_type)

          expect(survey_importer).to have_received(:import).with(parsed_response)
        end

        it 'returns the survey type' do
          result = importer.import(survey_type)
          expect(result[:survey_type]).to eq survey_type
        end
      end
    end
  end
end
