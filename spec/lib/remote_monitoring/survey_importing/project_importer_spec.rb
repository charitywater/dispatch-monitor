require 'spec_helper'

module RemoteMonitoring
  module SurveyImporting
    describe ProjectImporter do
      let(:wazi_importer) { double(:wazi_importer, import: nil) }
      let(:importer) { ProjectImporter.new(wazi_importer: wazi_importer) }

      describe '#import' do
        let(:deployment_code) { 'LR.CON.Q1.09.036.020' }
        let(:fs_response_id) { 11 }

        let(:v1) do
          double(
            :v1,
            deployment_code: deployment_code,
            fs_survey_id: 51399,
            fs_response_id: fs_response_id,
            inventory_type: 'Hand Pump - Something',
          )
        end

        before do
          allow(Project).to receive(:find_by) { project }
        end

        context 'with a valid deployment code' do
          let(:project) { Project.new }

          before do
            allow(project).to receive(:id) { 11 }
          end

          context 'project exists in app' do
            it 'does not re-import the existing projects' do
              importer.import(v1)

              expect(wazi_importer).not_to have_received(:import)
            end

            it 'returns the project' do
              result = importer.import(v1)
              expect(result).to eq project
            end
          end

          context 'project does not exist in app' do
            let(:project_from_wazi) { Project.new }

            before do
              allow(Project).to receive(:find_by).and_return(nil, project_from_wazi)
            end

            it 'imports the project' do
              importer.import(v1)

              expect(wazi_importer).to have_received(:import)
                .with(deployment_code: deployment_code)
            end

            it 'returns the project from wazi' do
              result = importer.import(v1)
              expect(result).to eq project_from_wazi
            end
          end

          context 'project does not exist in app and cannot get imported from wazi' do
            before do
              allow(Project).to receive(:find_by).and_return(nil, nil)
            end

            it 'returns nil' do
              expect(importer.import(v1)).to be_nil
            end
          end
        end

        context 'when there is a uri exception' do
          let(:project) { nil }
          let(:exception) { URI::InvalidURIError.new 'bad' }

          before do
            allow(ErrorNotifier).to receive(:notify)
            allow(wazi_importer).to receive(:import).and_raise(exception)
          end

          it 'notifies with the exception' do
            result = importer.import(v1)

            expect(ErrorNotifier).to have_received(:notify).with(exception).once
            expect(result).to be_nil
          end
        end
      end
    end
  end
end
