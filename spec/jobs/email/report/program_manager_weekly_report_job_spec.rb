require 'spec_helper'

module Email
  module Report
    describe ProgramManagerWeeklyReportJob do
      specify do
        expect(Email::Report::ProgramManagerWeeklyReportJob.queue).to eq :email
      end

      describe '.perform' do
        let(:data_id) { double(:data_id) }
        let(:email) { double(:email, deliver: true) }
        let(:data) { double(:data) }
        let(:job_data) { double(:job_data, data: data, destroy: true) }

        before do
          allow(::Report::WeeklyReportMailer).to receive(:weekly_report_results) { email }
          allow(JobData).to receive(:find).with(data_id) { job_data }
        end

        it 'delivers the email' do
          Email::Report::ProgramManagerWeeklyReportJob.perform(data_id)

          expect(::Report::WeeklyReportMailer).to have_received(:weekly_report_results).with(data)
          expect(email).to have_received(:deliver)
        end

        it 'destroys its JobData' do
          Email::Report::ProgramManagerWeeklyReportJob.perform(data_id)

          expect(job_data).to have_received(:destroy)
        end
      end
    end
  end
end
