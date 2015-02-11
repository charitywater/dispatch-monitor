require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe ProjectUpdater do
      let(:processor) { ProjectUpdater.new }

      describe '#process' do
        let(:project) { double(:project, update: true) }
        let(:new_status) { double(:new_status) }

        let(:policy) do
          double(
            :policy,
            update_project_status?: update_project_status?,
            new_status: new_status,
            project: project,
          )
        end

        context 'when the status changed' do
          let(:update_project_status?) { true }

          it 'updates the project status' do
            processor.process(policy)

            expect(project).to have_received(:update).with(status: new_status)
          end
        end

        context 'when the status did not change' do
          let(:update_project_status?) { false }

          it 'does nothing' do
            processor.process(policy)

            expect(project).not_to have_received(:update)
          end
        end
      end
    end
  end
end
