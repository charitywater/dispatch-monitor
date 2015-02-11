require 'spec_helper'

module Report
  module WeeklyReport
    describe ProgramManagerWeeklyReportJob do
      specify do
        expect(Report::ProgramManagerReportJob.queue).to eq :report
      end

      describe '.perform' do
        let(:job_data) { double(:job_data, id: 'job_data_id') }

        before do
          partner = create(:partner, name: 'REST')
          country = create(:country, name: 'Ethiopia')
          program = create(:program, country: country, partner: partner)
          admin_account = create(:account, :admin)
          program_manager_account = create(:account, :program_manager, program: program, weekly_subscription: true)
          program_manager_account_not_subscribed = create(:account, :program_manager, program: program, weekly_subscription: false)
          program_manager_account_not_subscribed_2 = create(:account, :program_manager, program: program, weekly_subscription: false)

          results = {
            program: program, 
            week_start: 'week_start'
          }

          allow(RemoteMonitoring::JobQueue).to receive(:enqueue)

          allow(Report::WeeklyReport::ProgramManagerWeeklyReportJob).to receive(:report_data) { results }

          allow(JobData).to receive(:create)
            .with(data: { results: results, recipient_id: program_manager_account.id })
            .and_return(job_data)
        end

        it 'enqueues the weekly report email only for subscribed program manager accounts' do
          Report::WeeklyReport::ProgramManagerWeeklyReportJob.perform

          expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
            Email::Report::ProgramManagerWeeklyReportJob,
            'job_data_id'
          )
        end
      end
    end
  end
end