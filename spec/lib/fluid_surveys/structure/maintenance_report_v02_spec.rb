require 'spec_helper'

module FluidSurveys
  module Structure
    describe MaintenanceReportV02 do
      specify do
        expect(MaintenanceReportV02.survey_id).to eq 57040
      end

      let(:v02) { MaintenanceReportV02.new(api) }
      let(:deployment_code_country) { 'LR' }
      let(:deployment_code_partner) { 'CON' }
      let(:deployment_code_quarter) { 'Q1' }
      let(:deployment_code_year) { '09' }
      let(:deployment_code_grant) { '036' }
      let(:deployment_code_point) { '020' }
      let(:deployment_code_optional) { '000' }
      let(:flowing_water) { 'Yes' }
      let(:consumable_water) { 'Yes' }
      let(:maintenance_visit) { 'No' }
      let(:notes) { 'Notes' }
      let(:repairs_successful) { 'Yes' }
      let(:unsuccessful_repair_reason) { 'Complete rehabilitation is needed' }

      let(:api) do
        {
          'rXB5grAKHT_0' => deployment_code_country,
          'rXB5grAKHT_1' => deployment_code_partner,
          'rXB5grAKHT_2' => deployment_code_quarter,
          'rXB5grAKHT_3' => deployment_code_year,
          'rXB5grAKHT_4' => deployment_code_grant,
          'rXB5grAKHT_5' => deployment_code_point,
          'rXB5grAKHT_6' => deployment_code_optional,
          'JOtRvhF37z' => flowing_water,
          'gshGGAKc8i' => maintenance_visit,
          'JkuCA9JrTB' => consumable_water,
          '6yIG9h9Lqk' => repairs_successful,
          'HOUKL73PP6' => 'Hand pump: Afridev',
          'J390tGE6go' => unsuccessful_repair_reason,
          '0nEsoTSiSN' => notes,
          '_id' => 11,
          '_created_at' => '2011-02-11T00:01:02.005',
        }
      end

      specify do
        expect(v02.fs_response_id).to eq 11
      end

      specify do
        expect(v02.fs_survey_id).to eq 57040
      end

      specify do
        expect(v02.inventory_type).to eq 'Hand pump: Afridev'
      end

      it 'strips the milliseconds off the submitted_at' do
        expect(v02.submitted_at).to eq Time.zone.parse('2011-02-11T00:01:02')
      end

      describe '#deployment_code' do
        context 'optional is present' do
          let(:deployment_code_optional) { '001' }

          specify do
            expect(v02.deployment_code).to eq 'LR.CON.Q1.09.036.020.001'
          end
        end

        context 'optional is blank' do
          let(:deployment_code_optional) { '000' }

          specify do
            expect(v02.deployment_code).to eq 'LR.CON.Q1.09.036.020'
          end
        end
      end

      describe '#valid?' do
        context 'present deployment code with optional' do
          let(:deployment_code_optional) { '123' }

          specify do
            expect(v02.valid?).to be_truthy
          end
        end

        context 'present but non-matching code' do
          let(:deployment_code_grant) { 'XXX' }

          specify do
            expect(v02.valid?).to be_falsey
          end
        end
      end

      describe '#repairs_successful?' do
        context 'repairs were successful' do
          let(:repairs_successful) { 'Yes' }

          specify do
            expect(v02.repairs_successful?).to be true
          end
        end

        context 'repairs were not successful' do
          let(:repairs_successful) { 'No' }

          specify do
            expect(v02.repairs_successful?).to be false
          end
        end
      end

      describe '#now_inactive?' do
        context 'rehab is required' do
          [
            'Complete rehabilitation is needed',
            'Depletion of water table',
            'Water point was abandoned',
            'Water point is not accessible due to political strife/war',
            'Water is contaminated',
          ].each do |reason|
            let(:unsuccessful_repair_reason) { reason }

            specify do
              expect(v02.now_inactive?).to be true
            end
          end
        end

        context 'rehab is not required' do
          [
            'Need more time, tools or spare parts',
            'Not sure',
            'Other',
          ].each do |reason|
            let(:unsuccessful_repair_reason) { reason }

            specify do
              expect(v02.now_inactive?).to be false
            end
          end
        end
      end

      describe '#status' do
        context 'water is flowing' do
          let(:flowing_water) { 'Yes' }

          context 'water is being consumed' do
            let(:consumable_water) { 'Yes' }

            context 'maintenance is required' do
              let(:maintenance_visit) { 'Yes' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end

            context 'maintenance is not required' do
              let(:maintenance_visit) { 'No' }

              it 'returns flowing' do
                expect(v02.status).to eq :flowing
              end
            end
          end

          context 'water is not being consumed' do
            let(:consumable_water) { 'No' }

            context 'maintenance is required' do
              let(:maintenance_visit) { 'Yes' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end

            context 'maintenance is not required' do
              let(:maintenance_visit) { 'No' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end
          end

          context 'water consumption cannot be determined' do
            let(:consumable_water) { 'Unknown / Unable to Answer' }

            context 'maintenance is required' do
              let(:maintenance_visit) { 'Yes' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end

            context 'maintenance is not required' do
              let(:maintenance_visit) { 'No' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end
          end
        end

        context 'water is not flowing' do
          let(:flowing_water) { 'No' }

          context 'water is being consumed' do
            let(:consumable_water) { 'Yes' }

            context 'maintenance is required' do
              let(:maintenance_visit) { 'Yes' }

              it 'returns needs_maintenance' do
                expect(v02.status).to eq :needs_maintenance
              end
            end

            context 'maintenance is not required' do
              let(:maintenance_visit) { 'No' }

              it 'returns needs_maintenance' do
                expect(v02.status).to eq :needs_maintenance
              end
            end
          end

          context 'water is not being consumed' do
            let(:consumable_water) { 'No' }

            context 'maintenance is required' do
              let(:maintenance_visit) { 'Yes' }

              it 'returns needs_maintenance' do
                expect(v02.status).to eq :needs_maintenance
              end
            end

            context 'maintenance is not required' do
              let(:maintenance_visit) { 'No' }

              it 'returns needs_maintenance' do
                expect(v02.status).to eq :needs_maintenance
              end
            end
          end

          context 'water consumption cannot be determined' do
            let(:consumable_water) { 'Unknown / Unable to Answer' }

            context 'maintenance is required' do
              let(:maintenance_visit) { 'Yes' }

              it 'returns needs_maintenance' do
                expect(v02.status).to eq :needs_maintenance
              end
            end

            context 'maintenance is not required' do
              let(:maintenance_visit) { 'No' }

              it 'returns needs_maintenance' do
                expect(v02.status).to eq :needs_maintenance
              end
            end
          end
        end

        context 'water flow cannot be determined' do
          let(:flowing_water) { 'Unable to Access' }

          context 'water is being consumed' do
            let(:consumable_water) { 'Yes' }

            context 'maintenance is required' do
              let(:maintenance_visit) { 'Yes' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end

            context 'maintenance is not required' do
              let(:maintenance_visit) { 'No' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end
          end

          context 'water is not being consumed' do
            let(:consumable_water) { 'No' }

            context 'maintenance is required' do
              let(:maintenance_visit) { 'Yes' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end

            context 'maintenance is not required' do
              let(:maintenance_visit) { 'No' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end
          end

          context 'water consumption cannot be determined' do
            let(:consumable_water) { 'Unknown / Unable to Answer' }

            context 'maintenance is required' do
              let(:maintenance_visit) { 'Yes' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end

            context 'maintenance is not required' do
              let(:maintenance_visit) { 'No' }

              it 'returns needs_visit' do
                expect(v02.status).to eq :needs_visit
              end
            end
          end
        end
      end  # describe #status

      describe '#notes' do
        let(:notes) { 'Some notes' }

        specify do
          expect(v02.notes).to eq 'Some notes'
        end
      end
    end
  end
end
