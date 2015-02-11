require 'spec_helper'

module RemoteMonitoring
  module SurveyImporting
    describe MaintenanceReportImporter do
      let(:post_processors) { [double(:processor, process: true)] }
      let(:importer) { MaintenanceReportImporter.new(post_processors) }

      describe '#import' do
        let(:survey_type) { double(:survey_type) }
        let(:submitted_at) { double(:submitted_at) }
        let(:response) { double(:response) }
        let(:project) { double(:project, id: 5) }
        let(:deployment_code) { double(:deployment_code) }
        let(:survey_response) { double(:survey_response, update: true) }
        let(:parsed_response) do
          double(
            :parsed_response,
            fs_survey_id: 1,
            fs_response_id: 11,
            survey_type: survey_type,
            submitted_at: submitted_at,
            deployment_code: deployment_code,
            response: response,
            valid?: valid,
          )
        end
        let(:policy) { double(:policy) }

        before do
          allow(Project).to receive(:find_by).with(deployment_code: deployment_code) { project }
          allow(SurveyResponse).to receive(:find_or_initialize_by) { survey_response }
          allow(PostProcessor::SurveyPolicy).to receive(:new).with(survey_response) { policy }
        end

        context 'valid' do
          let(:valid) { true }

          context 'project exists' do
            it 'creates a SurveyResponse' do
              importer.import(parsed_response)

              expect(SurveyResponse).to have_received(:find_or_initialize_by)
                .with(fs_response_id: 11)

              expect(survey_response).to have_received(:update).with(
                fs_survey_id: 1,
                project_id: project.id,
                survey_type: survey_type,
                response: response,
                submitted_at: submitted_at,
              )
            end

            it 'returns the survey response' do
              expect(importer.import(parsed_response)).to eq survey_response
            end

            it 'calls the post processors' do
              importer.import(parsed_response)

              post_processors.each do |processor|
                expect(processor).to have_received(:process).with(policy)
              end
            end
          end

          context 'project does not exist' do
            let(:valid) { true }
            let(:project) { nil }

            it 'does not import the survey response' do
              importer.import(parsed_response)

              expect(SurveyResponse).not_to have_received(:find_or_initialize_by)
            end

            it 'does not call the post processors' do
              importer.import(parsed_response)

              post_processors.each do |processor|
                expect(processor).not_to have_received(:process)
              end
            end

            it 'returns nil' do
              expect(importer.import(parsed_response)).to be_nil
            end

          end
        end

        context 'invalid' do
          let(:valid) { false }

          it 'does not import the survey response' do
            importer.import(parsed_response)

            expect(Project).not_to have_received(:find_by)
            expect(SurveyResponse).not_to have_received(:find_or_initialize_by)
          end

          it 'does not call the post processors' do
            importer.import(parsed_response)

            post_processors.each do |processor|
              expect(processor).not_to have_received(:process)
            end
          end

          it 'returns nil' do
            expect(importer.import(parsed_response)).to be_nil
          end
        end
      end
    end
  end
end
