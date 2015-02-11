require 'spec_helper'

module RemoteMonitoring
  module SurveyImporting
    describe SourceObservationImporter do
      let(:project_importer) { double(:project_importer) }
      let(:processors) { [double(:processor1, process: true), double(:processor2, process: true)] }
      let(:importer) do
        SourceObservationImporter.new(
          project_importer: project_importer,
          post_processors: processors
        )
      end

      describe '#import' do
        let(:parsed_response) do
          double(
            :parsed_response,
            valid?: valid?,
            fs_response_id: fs_response_id,
            fs_survey_id: fs_survey_id,
            submitted_at: submitted_at,
            survey_type: survey_type,
            response: response,
          )
        end
        let(:survey_response) { double(:survey_response, update: true) }
        let(:policy) { double(:policy) }
        let(:fs_response_id) { 132 }
        let(:fs_survey_id) { 3 }
        let(:submitted_at) { 'Time' }
        let(:response) { double(:response) }
        let(:survey_type) { :type }

        before do
          allow(PostProcessor::SurveyPolicy).to receive(:new).with(survey_response) { policy }
          allow(project_importer).to receive(:import).with(parsed_response) { project }
        end

        context 'when the parsed response is valid' do
          let(:valid?) { true }

          before do
            allow(SurveyResponse).to receive(:find_or_initialize_by)
              .with(fs_response_id: fs_response_id) { survey_response }
          end

          context 'when the project is imported' do
            let(:project) { double(:project) }

            it 'imports the survey response' do
              importer.import(parsed_response)

              expect(survey_response).to have_received(:update).with(
                fs_survey_id: fs_survey_id,
                project: project,
                survey_type: survey_type,
                response: response,
                submitted_at: submitted_at,
              )
            end

            it 'returns the survey_response' do
              expect(importer.import(parsed_response)).to eq survey_response
            end

            it 'calls the processors with the survey_response' do
              importer.import(parsed_response)

              processors.each do |processor|
                expect(processor).to have_received(:process).with(policy)
              end
            end
          end

          context 'when the project could not be imported' do
            let(:project) { nil }

            it 'does not import the survey response' do
              importer.import(parsed_response)

              expect(SurveyResponse).not_to have_received(:find_or_initialize_by)
            end

            it 'returns nil' do
              expect(importer.import(parsed_response)).to be_nil
            end

            it 'does not call the processors' do
              importer.import(parsed_response)

              processors.each do |processor|
                expect(processor).not_to have_received(:process)
              end
            end
          end
        end

        context 'when the parsed response is invalid' do
          let(:valid?) { false }

          it 'returns nil' do
            expect(importer.import(parsed_response)).to be_nil
          end

          it 'does not call the processors' do
            importer.import(parsed_response)

            processors.each do |processor|
              expect(processor).not_to have_received(:process)
            end
          end
        end
      end
    end
  end
end
