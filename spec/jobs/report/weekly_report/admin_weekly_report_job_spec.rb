require 'spec_helper'

module Report
  module WeeklyReport
    describe AdminWeeklyReportJob do
      specify do
        expect(Report::AdminReportJob.queue).to eq :report
      end

      describe '.perform' do
        let(:job_data_subscriber) { double(:job_data, id: 'job_data_subscriber_id') }

        before do
          partner = create(:partner, name: 'REST')
          country = create(:country, name: 'Ethiopia')
          program = create(:program, country: country, partner: partner)
          admin_account = create(:account, :admin, weekly_subscription: true)
          admin_account_not_subscribed = create(:account, :admin, weekly_subscription: false)
          admin_account_not_subscribed_2 = create(:account, :admin, weekly_subscription: false)
          program_manager_account = create(:account, :program_manager, program: program)

          results = {
            program: nil, 
            week_start: 'week_start'
          }

          allow(RemoteMonitoring::JobQueue).to receive(:enqueue)

          allow(Report::WeeklyReport::AdminWeeklyReportJob).to receive(:report_data) { results }

          allow(JobData).to receive(:create)
            .with(data: { results: results, recipient_id: admin_account.id })
            .and_return(job_data_subscriber)
        end

        it 'enqueues the weekly report email for only a subscribed admin account' do
          Report::WeeklyReport::AdminWeeklyReportJob.perform

          expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
            Email::Report::AdminWeeklyReportJob,
            'job_data_subscriber_id'
          )
        end
      end
    end
  end
end