module Email
  module Report
    class ProgramManagerWeeklyReportJob < BaseJob
      def self.email(data_id)
        job_data = JobData.find(data_id)
        ::Report::WeeklyReportMailer.weekly_report_results(job_data.data).tap do |_|
          job_data.destroy
        end
      end
    end
  end
end