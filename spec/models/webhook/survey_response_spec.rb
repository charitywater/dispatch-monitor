require 'spec_helper'

module Webhook
  describe SurveyResponse do
    let(:survey_response) { Webhook::SurveyResponse.new(params) }
    let(:params) { { survey_type: survey_type, other: 'another' } }
    let(:survey_type) { 'source_observation_v1' }

    describe '#survey_type' do
      specify do
        expect(survey_response.survey_type).to eq 'source_observation_v1'
      end
    end

    describe '#save' do
      before do
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue)
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue_in)
      end

      context 'source_observation?' do
        let(:survey_type) { 'source_observation_v1' }

        it 'enqueues a SourceObservationJob' do
          survey_response.save

          expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
            Import::SourceObservationJob,
            params
          )
        end
      end

      context 'maintenance_report?' do
        let(:survey_type) { 'maintenance_report_v02' }

        it 'enqueues a MaintenanceReportJob' do
          survey_response.save

          expect(RemoteMonitoring::JobQueue).to have_received(:enqueue_in).with(
            30.minutes,
            Import::MaintenanceReportJob,
            params
          )
        end
      end

      context 'sensor_registration?' do
        let(:survey_type) { 'sensor_registration_afd1' }

        it 'enqueues a SensorRegistrationJob' do
          survey_response.save

          expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
            Import::SensorRegistrationJob,
            params
          )
        end
      end

      context 'other type' do
        let(:survey_type) { 'other' }

        it 'does nothing' do
          survey_response.save

          expect(RemoteMonitoring::JobQueue).not_to have_received(:enqueue)
        end
      end
    end
  end
end
