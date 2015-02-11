require 'spec_helper'

module RemoteMonitoring
  module WaziImporting
    describe Importer do
      let(:client) { double(:client) }
      let(:project_importer) { double(:project_importer) }
      let(:wazi_importer) { Importer.new(client: client, project_importer: project_importer) }

      describe '#import' do
        let(:wazi_project_1) { { 'id' => 1, 'deployment_code' => 'DEP1' } }
        let(:wazi_project_2) { { 'id' => 2, 'deployment_code' => 'DEP2' } }
        let(:wazi_project_3) { { 'id' => 3, 'deployment_code' => 'DEP1' } }
        let(:dep1_projects) { [wazi_project_1, wazi_project_3] }
        let(:dep2_projects) { [wazi_project_2] }

        let(:project1) { double(:project1, previous_changes: { id: nil }) }
        let(:project2) { double(:project2, previous_changes: { id: nil }) }
        let(:project3) { double(:project3, previous_changes: { id: nil }) }

        before do
          allow(client).to receive(:projects).with(deployment_code: 'DEP1') { dep1_projects }
          allow(client).to receive(:projects).with(deployment_code: 'DEP2') { dep2_projects }

          allow(project_importer).to receive(:import).with(wazi_project_1) { project1 }
          allow(project_importer).to receive(:import).with(wazi_project_2) { project2 }
          allow(project_importer).to receive(:import).with(wazi_project_3) { project3 }
        end

        context 'valid deployment_codes' do
          it 'creates all the projects' do
            wazi_importer.import(deployment_code: %w(DEP1 DEP2))

            expect(project_importer).to have_received(:import).with(wazi_project_1)
            expect(project_importer).to have_received(:import).with(wazi_project_2)
            expect(project_importer).to have_received(:import).with(wazi_project_3)
          end

          it 'returns all the results' do
            results = wazi_importer.import(deployment_code: %w(DEP1 DEP2))

            expect(results[:created].to_a).to eq %w(DEP1 DEP2)
            expect(results[:updated].to_a).to be_empty
            expect(results[:invalid].to_a).to be_empty
          end
        end

        context 'existing deployment_codes' do
          let(:project1) { double(:project1, previous_changes: {}) }

          it 'sets results[:updated] with the existing deployment codes' do
            results = wazi_importer.import(deployment_code: %w(DEP1 DEP2))

            expect(results[:updated].to_a).to eq ['DEP1']
          end
        end

        context 'invalid deployment codes' do
          let(:dep2_projects) { [] }

          it 'sets results[:invalid] with the invalid deployment codes' do
            results = wazi_importer.import(deployment_code: %w(DEP1 DEP2))

            expect(results[:invalid].to_a).to eq ['DEP2']
          end
        end

        context 'blank deployment codes' do
          let(:dep2_projects) { nil }

          it 'sets results[:invalid] with the invalid deployment codes' do
            results = wazi_importer.import(deployment_code: %w(DEP1 DEP2))

            expect(results[:invalid].to_a).to eq ['DEP2']
          end
        end
      end
    end
  end
end
