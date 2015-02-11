require 'spec_helper'

module FluidSurveys
  module Structure
    describe SourceObservationV1 do
      specify do
        expect(SourceObservationV1.survey_id).to eq 51399
      end

      let(:v1) { SourceObservationV1.new(api) }
      let(:deployment_code) { ' LR.CON.Q1.09.036.020  ' }
      let(:flowing_water) { 'Yes' }
      let(:maintenance_visit) { 'No' }
      let(:notes) { 'Notes' }
      let(:api) do
        {
          'icJ0bt2hs1' => deployment_code,
          'qVreqGQpLA' => flowing_water,
          'EbwEfSdETT' => 'Hand Pump: Afridev',
          'hqSVwuhttr' => maintenance_visit,
          'oDqhgFtgGQ' => notes,
          '_id' => 11,
          '_created_at' => '2011-02-11T00:01:02.005',
        }
      end

      specify do
        expect(v1.deployment_code).to eq 'LR.CON.Q1.09.036.020'
      end

      specify do
        expect(v1.fs_response_id).to eq 11
      end

      specify do
        expect(v1.fs_survey_id).to eq 51399
      end

      specify do
        expect(v1.inventory_type).to eq 'Hand Pump: Afridev'
      end

      it 'strips the milliseconds off the submitted_at' do
        expect(v1.submitted_at).to eq Time.zone.parse('2011-02-11T00:01:02')
      end

      describe '#status' do
        context 'water is flowing' do
          let(:flowing_water) { 'Yes' }

          context 'maintenance is required' do
            let(:maintenance_visit) { 'Yes' }

            it 'returns needs_visit' do
              expect(v1.status).to eq :needs_visit
            end
          end

          context 'maintenance is not required' do
            let(:maintenance_visit) { 'No' }

            it 'returns flowing' do
              expect(v1.status).to eq :flowing
            end
          end
        end

        context 'water is not flowing' do
          let(:flowing_water) { 'No' }

          context 'maintenance is required' do
            let(:maintenance_visit) { 'Yes' }

            it 'returns needs_maintenance' do
              expect(v1.status).to eq :needs_maintenance
            end
          end

          context 'maintenance is not required' do
            let(:maintenance_visit) { 'No' }

            it 'returns needs_maintenance' do
              expect(v1.status).to eq :needs_maintenance
            end
          end
        end

        context 'water flow cannot be determined' do
          let(:flowing_water) { 'Unable to Access' }

          context 'maintenance is required' do
            let(:maintenance_visit) { 'Yes' }

            it 'returns needs_visit' do
              expect(v1.status).to eq :needs_visit
            end
          end

          context 'maintenance is not required' do
            let(:maintenance_visit) { 'No' }

            it 'returns needs_visit' do
              expect(v1.status).to eq :needs_visit
            end
          end
        end
      end  # describe #status

      describe '#notes' do
        let(:notes) { 'Some notes' }

        specify do
          expect(v1.notes).to eq 'Some notes'
        end
      end

      describe '#valid?' do
        context 'blank deployment code' do
          let(:deployment_code) { '' }

          specify do
            expect(v1.valid?).to be_falsey
          end
        end

        context 'present deployment code' do
          let(:deployment_code) { 'LR.CON.Q1.09.036.020' }

          specify do
            expect(v1.valid?).to be_truthy
          end
        end

        context 'present but non-matching code' do
          let(:deployment_code) { 'LR.CON.Q1.09.XXX.020' }

          specify do
            expect(v1.valid?).to be_falsey
          end
        end
      end
    end
  end
end
