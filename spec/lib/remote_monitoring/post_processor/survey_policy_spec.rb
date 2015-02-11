require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe SurveyPolicy do
      let(:structure) do
        double(
          :structure,
          status: new_status,
          repairs_successful?: repairs_successful?,
          now_inactive?: now_inactive?,
        )
      end

      let(:project) { create(:project, old_status) }

      let(:survey_response) do
        double(
          :survey_response,
          project: project,
          structure: structure,
          source_observation?: source_observation?,
          maintenance_report?: maintenance_report?,
          submitted_at: Time.zone.now,
        )
      end
      let(:source_observation?) { false }
      let(:maintenance_report?) { false }
      let(:repairs_successful?) { false }
      let(:now_inactive?) { false }
      let(:old_status) { :flowing }
      let(:new_status) { :hello }

      let(:policy) { PostProcessor::SurveyPolicy.new(survey_response) }

      describe '#happened_at' do
        it 'returns the survey response’s submitted_at' do
          expect(policy.happened_at).to eq survey_response.submitted_at
        end
      end

      describe '#new_status' do
        context 'source observation' do
          let(:source_observation?) { true }

          it 'returns the status from the structure' do
            expect(policy.new_status).to eq structure.status
          end
        end

        context 'maintenance report' do
          let(:maintenance_report?) { true }
          let(:old_status) { :needs_visit }

          context 'repairs were successful' do
            let(:repairs_successful?) { true }

            it 'returns the status from the structure' do
              expect(policy.new_status).to eq structure.status
            end
          end

          context 'repairs were unsuccessful' do
            let(:repairs_successful?) { false }

            context 'now inactive' do
              let(:now_inactive?) { true }

              specify do
                expect(policy.new_status).to eq :inactive
              end
            end

            context 'not now inactive' do
              let(:now_inactive?) { false }

              specify do
                expect(policy.new_status).to eq :needs_maintenance
              end
            end
          end

          context 'unprocessable' do
            let(:old_status) { :flowing }

            specify do
              expect(policy.new_status).to eq :flowing
            end
          end
        end
      end # new_status

      describe '#update_project_status?' do
        let(:old_status) { :needs_maintenance }

        context 'status changed' do
          let(:new_status) { :flowing }

          context 'there are no future status changed activities' do
            context 'source observation survey' do
              let(:source_observation?) { true }
              let(:maintenance_report?) { false }

              specify do
                expect(policy.update_project_status?).to eq true
              end
            end

            context 'maintenance report' do
              let(:source_observation?) { false }
              let(:maintenance_report?) { true }

              context 'processable' do
                let(:old_status) { :needs_maintenance }
                let(:repairs_successful?) { true }

                specify do
                  expect(policy.update_project_status?).to eq true
                end
              end

              context 'not processable' do
                let(:old_status) { :inactive }

                specify do
                  expect(policy.update_project_status?).to eq false
                end
              end
            end
          end

          context 'there are future status changed activities' do
            let(:new_status) { :flowing }
            let(:source_observation?) { true }
            let(:maintenance_report?) { false }

            before do
              create(
                :activity,
                :status_changed,
                happened_at: 300.years.from_now,
                project: project
              )
            end

            specify do
              expect(policy.update_project_status?).to eq false
            end
          end
        end

        context 'status did not change' do
          let(:new_status) { old_status }

          specify do
            expect(policy.update_project_status?).to eq false
          end
        end
      end
    end
  end
end
