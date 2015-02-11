require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe MaintenanceReportActivityCreator do
      let(:processor) { MaintenanceReportActivityCreator.new }

      describe '#process' do
        let(:policy) do
          double(
            :policy,
            create_maintenance_report_activity?: create_maintenance_report_activity?,
            survey_response: survey_response,
          )
        end
        let(:submitted_at) { DateTime.new(2014) }
        let(:survey_response) do
          build(
            :survey_response,
            project_id: 4,
            fs_survey_id: 5,
            fs_response_id: 6,
            submitted_at: submitted_at
          )
        end

        context 'maintenance report activity should be created' do
          let(:create_maintenance_report_activity?) { true }

          context 'new activity' do
            it 'creates a maintenance report received activity' do
              processor.process(policy)

              expect(Activity.count).to eq 1

              activity = Activity.last
              expect(activity.happened_at).to eq submitted_at
              expect(activity.project_id).to eq 4
              expect(activity).to be_maintenance_report_received
              expect(activity.data['fs_survey_id']).to eq 5
              expect(activity.data['fs_response_id']).to eq 6
            end
          end

          context 'existing activity' do
            let!(:activity) do
              create(
                :activity,
                :maintenance_report_received,
                happened_at: submitted_at,
                project_id: 4,
                data: {
                  fs_survey_id: 0,
                  fs_response_id: 0,
                },
              )
            end

            it 'updates the existing activity' do
              processor.process(policy)

              expect(Activity.count).to eq 1

              activity.reload
              expect(activity.happened_at).to eq submitted_at
              expect(activity.project_id).to eq 4
              expect(activity).to be_maintenance_report_received
              expect(activity.data['fs_survey_id']).to eq 5
              expect(activity.data['fs_response_id']).to eq 6
            end
          end
        end

        context 'maintenance report activity should not be created' do
          let(:create_maintenance_report_activity?) { false }

          it 'does nothing' do
            processor.process(policy)

            expect(Activity.count).to eq 0
          end
        end
      end
    end
  end
end
