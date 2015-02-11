require 'spec_helper'

module Import
  describe Survey do
    let(:import_survey) { Import::Survey.new }
    let(:survey_type) { 'source_observation_v02' }

    describe 'validations' do
      it 'only accepts valid survey types' do
        SurveyResponse.all_types.each do |type|
          expect(import_survey).to allow_value(
            type.to_s
          ).for(:survey_type)
        end

        expect(import_survey).not_to allow_value(
          'extra'
        ).for(:survey_type)
      end
    end

    describe '#save' do
      before do
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue)

        import_survey.survey_type = survey_type
      end

      context 'when valid' do
        it 'returns true' do
          expect(import_survey.save).to be_truthy
        end

        context 'source_observation' do
          let(:survey_type) { 'source_observation_v02' }

          it 'enqueues a SourceObservationsJob' do
            import_survey.save

            expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(SourceObservationsJob, survey_type)
          end
        end

        context 'maintenance_report' do
          let(:survey_type) { 'maintenance_report_v02' }
          it 'enqueues a MaintenanceReportsJob' do
            import_survey.save

            expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(MaintenanceReportsJob, survey_type)
          end
        end
      end

      context 'when invalid' do
        let(:survey_type) { 'invalid' }

        it 'returns false' do
          expect(import_survey.save).to be_falsey
        end

        it 'does nothing' do
          import_survey.save

          expect(RemoteMonitoring::JobQueue).not_to have_received(:enqueue)
        end
      end
    end
  end
end
