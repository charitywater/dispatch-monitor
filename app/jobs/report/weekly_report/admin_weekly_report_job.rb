module Report
  module WeeklyReport
    class AdminWeeklyReportJob < AdminReportJob
      def self.report_data
        {
          program: nil,
          week_start: Time.zone.now.utc.beginning_of_week
        }
      end

      def self.email_job
        Email::Report::AdminWeeklyReportJob
      end
    end
  end
end
