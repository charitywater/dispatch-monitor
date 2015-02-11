require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe ObservationSurveyActivityCreator do
      let(:processor) { ObservationSurveyActivityCreator.new }

      describe '#process' do
        let(:submitted_at) { DateTime.new(2011, 1, 2) }
        let(:survey_response) do
          double(
            :survey_response,
            submitted_at: submitted_at,
            project_id: 4,
            fs_survey_id: 5,
            fs_response_id: 6
          )
        end

        let(:policy) do
          double(
            :policy,
            create_source_observation_activity?: create_source_observation_activity?,
            survey_response: survey_response,
          )
        end

        context 'source observation activity should be created' do
          let(:create_source_observation_activity?) { true }

          context 'creating activity' do
            it 'creates the activity' do
              processor.process(policy)

              activity = Activity.last
              expect(activity.happened_at).to eq submitted_at
              expect(activity.project_id).to eq 4
              expect(activity.data['fs_survey_id']).to eq 5
              expect(activity.data['fs_response_id']).to eq 6
            end
          end

          context 'updating activity' do
            let!(:existing_activity) do
              create(
                :activity,
                :observation_survey_received,
                happened_at: submitted_at,
                project_id: 4,
                data: { fs_survey_id: 10, fs_response_id: 15 }
              )
            end

            it 'updates the activity' do
              processor.process(policy)

              activity = Activity.last

              expect(Activity.count).to eq 1
              expect(activity).to eq existing_activity.reload
              expect(activity.data['fs_survey_id']).to eq 5
              expect(activity.data['fs_response_id']).to eq 6
            end
          end
        end

        context 'source observation activity should not be created' do
          let(:create_source_observation_activity?) { false }

          it 'does nothing' do
            processor.process(policy)

            expect(Activity.count).to eq 0
          end
        end
      end
    end
  end
end
