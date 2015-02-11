require 'spec_helper'

module Import
  describe MaintenanceReportMailer do
    describe '.results' do
      let(:account) do
        double(
          :account,
          name: 'Kristy Conner',
          name_and_email: 'Kristy Conner <kristy.conner@example.com>',
        )
      end
      let(:survey_type) { :maintenance_report_v02 }
      let(:data) { {
        fs_survey_id: 1,
        fs_response_id: 2,
        deployment_code: 'AA.AAA.Q5.11.111.111'
      } }

      before do
        allow(Account).to receive(:find).with(5) { account }
      end

      it 'has the right subject' do
        email = MaintenanceReportMailer.results(
          results: [survey_type: survey_type, complete: [data]], recipient_id: 5
        )
        expect(email.subject).to eq 'Your Maintenance Report import has finished'
      end

      it 'has the right recipient' do
        email = MaintenanceReportMailer.results(results: [], recipient_id: 5)

        expect(email.to).to eq ['kristy.conner@example.com']
        expect(email.encoded).to include('Dear Kristy Conner,')
      end

      context 'repairs completed' do
        it 'shows the text when present' do
          email = MaintenanceReportMailer.results(
            results: [
              { survey_type: :maintenance_report_v02, complete: [data] },
              { survey_type: :test_maintenance_report_v02, complete: [data, data] },
            ],
            recipient_id: 5,
          )
          expect(email.encoded).to match(/
            Maintenance\sReport\sV.02
            .*?
            1\srepair\swas\scompleted
            .*?
            AA\.AAA\.Q5\.11\.111\.111
            .*?
            Test\sMaintenance\sReport\sV.02
            .*?
            2\srepairs\swere\scompleted
            .*?
            AA\.AAA\.Q5\.11\.111\.111
            .*?
            AA\.AAA\.Q5\.11\.111\.111
          /mx)
        end

        it 'hides the text when blank' do
          email = MaintenanceReportMailer.results(
            results: [survey_type: survey_type, complete: []], recipient_id: 5
          )
          expect(email.encoded).not_to include('complete')
        end
      end

      context 'repairs were not completed' do
        it 'shows the text when present' do
          email = MaintenanceReportMailer.results(
            results: [
              { survey_type: :maintenance_report_v02, incomplete: [data] },
              { survey_type: :test_maintenance_report_v02, incomplete: [data, data] },
            ],
            recipient_id: 5,
          )
          expect(email.encoded).to match(/
            Maintenance\sReport\sV.02
            .*?
            1\srepair\swas\snot\scompleted
            .*?
            AA\.AAA\.Q5\.11\.111\.111
            .*?
            Test\sMaintenance\sReport\sV.02
            .*?
            2\srepairs\swere\snot\scompleted
            .*?
            AA\.AAA\.Q5\.11\.111\.111
            .*?
            AA\.AAA\.Q5\.11\.111\.111
          /mx)
        end

        it 'hides the text when blank' do
          email = MaintenanceReportMailer.results(
            results: [survey_type: survey_type, incomplete: []], recipient_id: 5
          )
          expect(email.encoded).not_to include('complete')
        end
      end

      context 'inactive projects' do
        it 'shows the text when present' do
          email = MaintenanceReportMailer.results(results: [
              { survey_type: :maintenance_report_v02, inactive: [data] },
              { survey_type: :test_maintenance_report_v02, inactive: [data, data] },
            ],
            recipient_id: 5,
          )
          expect(email.encoded).to match(/
            Maintenance\sReport\sV.02
            .*?
            1\sproject\sis\sinactive
            .*?
            AA\.AAA\.Q5\.11\.111\.111
            .*?
            Test\sMaintenance\sReport\sV.02
            .*?
            2\sprojects\sare\sinactive
            .*?
            AA\.AAA\.Q5\.11\.111\.111
            .*?
            AA\.AAA\.Q5\.11\.111\.111
          /mx)
        end

        it 'hides the text when blank' do
          email = MaintenanceReportMailer.results(
            results: [survey_type: survey_type, inactive: []], recipient_id: 5
          )
          expect(email.encoded).not_to include('inactive')
        end
      end

      context 'invalid' do
        it 'shows the text when present' do
          email = MaintenanceReportMailer.results(
            results: [survey_type: survey_type, invalid: [data]], recipient_id: 5
          )
          expect(email.encoded).to include('1 maintenance report was invalid')

          email = MaintenanceReportMailer.results(
            results: [survey_type: survey_type, invalid: [data, data]],
            recipient_id: 5,
          )
          expect(email.encoded).to include('2 maintenance reports were invalid')
        end

        it 'hides the text when blank' do
          email = MaintenanceReportMailer.results(
            results: [survey_type: survey_type, invalid: []], recipient_id: 5
          )
          expect(email.encoded).not_to include('invalid')
        end
      end
    end
  end
end
