require 'spec_helper'

module FluidSurveys
  module Structure
    describe SourceObservationV02 do
      specify do
        expect(SourceObservationV02.survey_id).to eq 68483
      end

      let(:v02) { SourceObservationV02.new(api) }
      let(:deployment_code_country) { 'LR' }
      let(:deployment_code_partner) { 'CON' }
      let(:deployment_code_quarter) { 'Q1' }
      let(:deployment_code_year) { '09' }
      let(:deployment_code_grant) { '036' }
      let(:deployment_code_point) { '020' }
      let(:deployment_code_optional) { '000' }
      let(:flowing_water) { 'Yes' }
      let(:maintenance_visit) { 'No' }
      let(:consumable_water) { 'Yes' }
      let(:notes) { 'Notes' }

      let(:api) do
        {
          'icJ0bt2hs1_0' => deployment_code_country,
          'icJ0bt2hs1_1' => deployment_code_partner,
          'icJ0bt2hs1_2' => deployment_code_quarter,
          'icJ0bt2hs1_3' => deployment_code_year,
          'icJ0bt2hs1_4' => deployment_code_grant,
          'icJ0bt2hs1_5' => deployment_code_point,
          'icJ0bt2hs1_6' => deployment_code_optional,
          'PV5RcUw2ys' => flowing_water,
          'LkUlwEuUwP' => maintenance_visit,
          '5pXGXZwpaI' => consumable_water,
          'XBriGBeCyP' => 'Rain water: Rain water',
          '8Fxk9mToOG' => notes,
          '_id' => 11,
          '_created_at' => '2011-02-11T00:01:02.005',
        }
      end

      specify do
        expect(v02.fs_response_id).to eq 11
      end

      specify do
        expect(v02.fs_survey_id).to eq 68483
      end

      specify do
        expect(v02.inventory_type).to eq 'Rain water: Rain water'
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
