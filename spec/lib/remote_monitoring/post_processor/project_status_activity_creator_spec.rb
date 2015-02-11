require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe ProjectStatusActivityCreator do
      let(:processor) { ProjectStatusActivityCreator.new }

      describe '#process' do
        let(:project) { double(:project, id: 5) }

        let(:policy) do
          double(
            :policy,
            create_status_activity?: create_status_activity?,
            happened_at: DateTime.new(2014),
            project: project,
            new_status: new_status,
          )
        end

        let(:new_status) { :needs_maintenance }

        context 'status changed?' do
          let(:create_status_activity?) { true }
          let(:activity) { double :activity, update: true }
          let(:status_changed_activities) do
            double(:status_changed_activities, find_or_create_by: activity)
          end

          before do
            allow(project).to receive(:status_changed_to?) { false }

            allow(Activity).to receive(:status_changed) { status_changed_activities }
          end

          it 'creates a status changed activity with the new status' do
            processor.process(policy)

            expect(status_changed_activities).to have_received(
              :find_or_create_by
            ).with(
              happened_at: policy.happened_at,
              project_id: project.id,
            )

            expect(activity).to have_received(
              :update
            ).with(
              data: { status: Project.statuses[new_status] },
              sensor: nil
            )
          end
        end

        context 'status did not change' do
          let(:create_status_activity?) { false }

          before do
            allow(Activity).to receive(:status_changed)
          end

          it 'does nothing' do
            processor.process(policy)

            expect(Activity).not_to have_received(:status_changed)
          end
        end
      end
    end
  end
end
