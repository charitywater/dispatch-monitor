require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe SensorRegistrationPolicy do
      let(:device_number) { "DVT001" }
      let(:deployment_code) { "ET.GOH.Q4.09.148.001" }
      let(:error_code) { :error }
      let(:spreadsheet_exists?) { true }

      let(:structure) do
        double(
          :structure,
          device_number: device_number,
          deployment_code: deployment_code,
          error_code: error_code,
        )
      end

      let(:survey_response) do
        double(
          :survey_response,
          device_number: device_number,
          deployment_code: deployment_code,
          error_code: error_code,
          structure: structure,
          submitted_at: Time.zone.now,
        )
      end

      let(:policy) { PostProcessor::SensorRegistrationPolicy.new(survey_response) }

      describe '#happened_at' do
        it 'returns the survey response’s submitted_at' do
          expect(policy.happened_at).to eq survey_response.submitted_at
        end
      end

      describe '#deployment_code' do
        it 'returns the survey response deploy code' do
          expect(policy.deployment_code).to eq survey_response.deployment_code
        end
      end

      describe '#sensor_id' do
        it 'returns the survey response device number' do
          expect(policy.device_number).to eq survey_response.device_number
        end
      end

      describe '#spreadsheet_exists?' do
        before do
          allow(policy).to receive(:spreadsheet) { spreadsheet }
        end

        context 'there is no spreadsheet' do
          let(:spreadsheet) { nil }

          specify do
            expect(policy.spreadsheet_exists?).to eq false
          end
        end

        context 'there is a spreadsheet' do
          let(:spreadsheet) { true }

          specify do
            expect(policy.spreadsheet_exists?).to eq true
          end
        end
      end

      describe '#assign_sensor?' do
        before do
          allow(policy).to receive(:spreadsheet_exists?) { spreadsheet_exists? }
          allow(policy).to receive(:valid_deployment_code?) { valid_deployment_code? }
          allow(policy).to receive(:network_error?) { network_error? }
        end

        context 'there is no spreadsheet' do
          let(:spreadsheet_exists?) { false }
          let(:valid_deployment_code?) { true }
          let(:network_error?) { false }

          specify do
            expect(policy.assign_sensor?).to eq false
          end
        end

        context 'deploy code is invalid' do
          let(:spreadsheet_exists?) { true }
          let(:valid_deployment_code?) { false }
          let(:network_error?) { false }

          specify do
            expect(policy.assign_sensor?).to eq false
          end
        end

        context 'error code returns an error' do
          let(:spreadsheet_exists?) { true }
          let(:valid_deployment_code?) { true }
          let(:network_error?) { true }

          specify do
            expect(policy.assign_sensor?).to eq false
          end
        end

        context 'all data is valid' do
          let(:spreadsheet_exists?) { true }
          let(:valid_deployment_code?) { true }
          let(:network_error?) { false }

          specify do
            expect(policy.assign_sensor?).to eq true
          end
        end
      end

      describe '#valid_deployment_code?' do
        context 'invalid deploy code' do
          let(:deployment_code) { "ET.GOH.Q4.09.148" }

          specify do
            expect(policy.valid_deployment_code?).to eq false
          end
        end

        context 'valid deploy code' do
          let(:deployment_code) { "ET.GOH.Q4.09.148.001" }

          specify do
            expect(policy.valid_deployment_code?).to eq true
          end
        end
      end

      describe '#network_error?' do
        before do
          allow(policy).to receive(:error_code) { error_code }
        end

        context 'no error was returned' do
          let(:error_code) { :oH }

          specify do
            expect(policy.network_error?).to eq false
          end
        end

        context 'an error code is returned' do
          let(:error_code) { :not_an_ok_value }

          specify do
            expect(policy.network_error?).to eq true
          end
        end
      end
    end
  end
end
