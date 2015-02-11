require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe SensorPolicy do
      let(:policy) { SensorPolicy.new(sensor, weekly_log) }
      let(:sensor) { create(:sensor, project: project) }
      let(:project) { create(:project, old_status) }

      let(:weekly_log) do
        double(
          :weekly_log,
          normal_flow?: normal_flow?,
          received_at: Time.zone.now,
        )
      end

      let(:application_settings) do
        double(
          :application_settings,
          sensors_affect_project_status?: sensors_affect_project_status?,
        )
      end

      let(:old_status) { :unknown }
      let(:normal_flow?) { true }
      let(:sensors_affect_project_status?) { true }

      before do
        allow(ApplicationSettings).to receive(:first_or_create) { application_settings }
      end

      describe '#happened_at' do
        it 'returns the timestamp at which the packet was received' do
          expect(policy.happened_at).to eq weekly_log.received_at
        end
      end

      describe '#new_status' do
        context 'normal flow' do
          let(:normal_flow?) { true }

          context 'project was flowing' do
            let(:old_status) { :flowing }

            specify do
              expect(policy.new_status).to eq :flowing
            end
          end

          context 'project was needs_maintenance' do
            let(:old_status) { :needs_maintenance }

            context 'survey caused project to be needs_maintenance' do
              before do
                create(:activity, :status_changed_to_needs_maintenance, sensor: sensor, project: project)
                create(:activity, :status_changed_to_needs_maintenance, sensor: nil, project: project)
              end

              specify do
                expect(policy.new_status).to eq :needs_visit
              end
            end

            context 'sensor caused project to be needs_maintenance' do
              before do
                create(:activity, :status_changed_to_needs_maintenance, sensor: nil, project: project)
                create(:activity, :status_changed_to_needs_maintenance, sensor: sensor, project: project)
              end

              specify do
                expect(policy.new_status).to eq :flowing
              end
            end
          end

          context 'project was needs_visit' do
            let(:old_status) { :needs_visit }

            specify do
              expect(policy.new_status).to eq :needs_visit
            end
          end

          context 'project was unknown' do
            let(:old_status) { :unknown }

            specify do
              expect(policy.new_status).to eq :flowing
            end
          end

          context 'project was inactive' do
            let(:old_status) { :inactive }

            specify do
              expect(policy.new_status).to eq :needs_visit
            end
          end
        end

        context 'red flag' do
          let(:normal_flow?) { false }

          context 'project was flowing' do
            let(:old_status) { :flowing }

            specify do
              expect(policy.new_status).to eq :needs_maintenance
            end
          end

          context 'project was needs_maintenance' do
            let(:old_status) { :needs_maintenance }

            specify do
              expect(policy.new_status).to eq :needs_maintenance
            end
          end

          context 'project was needs_visit' do
            let(:old_status) { :needs_visit }

            specify do
              expect(policy.new_status).to eq :needs_maintenance
            end
          end

          context 'project was unknown' do
            let(:old_status) { :unknown }

            specify do
              expect(policy.new_status).to eq :needs_maintenance
            end
          end

          context 'project was inactive' do
            let(:old_status) { :inactive }

            specify do
              expect(policy.new_status).to eq :inactive
            end
          end
        end
      end

      describe '#status_changed?' do
        before do
          allow(policy).to receive(:new_status) { new_status }
        end

        context 'status is changing' do
          let(:old_status) { :inactive }
          let(:new_status) { :flowing }

          specify do
            expect(policy.status_changed?).to be true
          end
        end

        context 'status is not changing' do
          let(:old_status) { :needs_visit }
          let(:new_status) { :needs_visit }

          specify do
            expect(policy.status_changed?).to be false
          end
        end
      end

      describe '#update_project_status?' do
        before do
          allow(policy).to receive(:status_changed?) { status_changed? }
        end

        context 'status is changing' do
          let(:status_changed?) { true }

          context 'sensors affect project status' do
            let(:sensors_affect_project_status?) { true }

            specify do
              expect(policy.update_project_status?).to be true
            end
          end

          context 'sensors do not affect project status' do
            let(:sensors_affect_project_status?) { false }

            specify do
              expect(policy.update_project_status?).to be false
            end
          end
        end

        context 'status is not changing' do
          let(:status_changed?) { false }

          specify do
            expect(policy.update_project_status?).to be false
          end
        end
      end

      describe '#complete_previous_tickets?' do
        before do
          allow(policy).to receive(:new_status) { new_status }
        end

        context 'when project status was needs_maintenance' do
          let(:old_status) { :needs_maintenance }

          context 'status is no longer needs_maintenance' do
            let(:new_status) { :needs_visit }

            specify do
              expect(policy.complete_previous_tickets?).to be true
            end

            context 'sensors do not affect project status' do
              let(:sensors_affect_project_status?) { false }

              specify do
                expect(policy.complete_previous_tickets?).to be_falsey
              end
            end
          end

          context 'status is now flowing' do
            let(:new_status) { :flowing }

            specify do
              expect(policy.complete_previous_tickets?).to be true
            end

            context 'sensors do not affect project status' do
              let(:sensors_affect_project_status?) { false }

              specify do
                expect(policy.complete_previous_tickets?).to be_falsey
              end
            end
          end

          context 'status is still needs_maintenance' do
            let(:new_status) { :needs_maintenance }

            specify do
              expect(policy.complete_previous_tickets?).to be false
            end
          end
        end

        context 'when project status was needs_visit' do
          let(:old_status) { :needs_visit }

          context 'new status is needs_maintenance' do
            let(:new_status) { :needs_maintenance }

            specify do
              expect(policy.complete_previous_tickets?).to be true
            end

            context 'sensors do not affect project status' do
              let(:sensors_affect_project_status?) { false }

              specify do
                expect(policy.complete_previous_tickets?).to be_falsey
              end
            end
          end

          context 'new status is not needs_maintenance' do
            let(:new_status) { :inactive }

            specify do
              expect(policy.complete_previous_tickets?).to be false
            end
          end
        end

        context 'when project status was flowing' do
          let(:old_status) { :flowing }

          context 'new status is needs_maintenance' do
            let(:new_status) { :needs_maintenance }

            specify do
              expect(policy.complete_previous_tickets?).to be_falsey
            end
          end

          context 'new status is needs_visit' do
            let(:new_status) { :needs_visit }

            specify do
              expect(policy.complete_previous_tickets?).to be_falsey
            end
          end
        end
      end

      describe '#create_new_ticket?' do
        before do
          allow(policy).to receive(:new_status) { new_status }
        end

        context 'status has changed' do
          context 'new status is needs_visit' do
            let(:old_status) { :needs_maintenance }
            let(:new_status) { :needs_visit }

            specify do
              expect(policy.create_new_ticket?).to be_truthy
            end

            context 'sensors do not affect project status' do
              let(:sensors_affect_project_status?) { false }

              specify do
                expect(policy.create_new_ticket?).to be_falsey
              end
            end
          end

          context 'new status is needs_maintenance' do
            let(:old_status) { :needs_visit }
            let(:new_status) { :needs_maintenance }

            specify do
              expect(policy.create_new_ticket?).to be_truthy
            end

            context 'sensors do not affect project status' do
              let(:sensors_affect_project_status?) { false }

              specify do
                expect(policy.create_new_ticket?).to be_falsey
              end
            end
          end

          context 'new status is something else' do
            let(:new_status) { :any_other_status }

            specify do
              expect(policy.create_new_ticket?).to be_falsey
            end
          end
        end

        context 'status has not changed' do
          let(:new_status) { :needs_maintenance }
          let(:old_status) { new_status }

          specify do
            expect(policy.create_new_ticket?).to be_falsey
          end
        end
      end

      describe '#ticket_has_due_date?' do
        before do
          allow(policy).to receive(:new_status) { new_status }
        end

        context 'new status is needs_maintenance' do
          let(:new_status) { :needs_maintenance }

          specify do
            expect(policy.ticket_has_due_date?).to be true
          end
        end

        context 'new status is anything else' do
          let(:new_status) { :any_other_status }

          specify do
            expect(policy.ticket_has_due_date?).to be false
          end
        end
      end

      describe '#flowing_water_answer' do
        before do
          allow(policy).to receive(:new_status) { new_status }
        end

        context 'status has changed' do
          context 'new status is needs_visit' do
            let(:new_status) { :needs_visit }

            specify do
              expect(policy.flowing_water_answer).to eq 'Yes'
            end
          end

          context 'new status is needs_maintenance' do
            let(:new_status) { :needs_maintenance }

            specify do
              expect(policy.flowing_water_answer).to eq 'No'
            end
          end

          context 'new status is anything else' do
            let(:new_status) { :any_other_status }

            specify do
              expect(policy.flowing_water_answer).to be_nil
            end
          end
        end

        context 'status has not changed' do
          let(:new_status) { old_status }

          specify do
            expect(policy.flowing_water_answer).to be_nil
          end
        end
      end

      describe '#maintenance_visit_answer' do
        before do
          allow(policy).to receive(:create_new_ticket?) { create_new_ticket? }
        end

        context 'ticket is being created' do
          let(:create_new_ticket?) { true }

          context 'old status was inactive' do
            let(:old_status) { :inactive }

            specify do
              expect(policy.maintenance_visit_answer).to be_nil
            end
          end

          context 'old status was anything else' do
            let(:old_status) { :unknown }

            specify do
              expect(policy.maintenance_visit_answer).to eq 'Yes'
            end
          end
        end

        context 'ticket is not being created' do
          let(:create_new_ticket?) { false }
          let(:old_status) { :unknown }

          specify do
            expect(policy.maintenance_visit_answer).to be_nil
          end
        end
      end
    end
  end
end
