module Report
  module WeeklyReport
    class ProgramManagerWeeklyReportJob < ProgramManagerReportJob
      def self.report_data(program)
        {
          program: program,
          week_start: Time.zone.now.utc.beginning_of_week
        }
      end

      def self.email_job
        Email::Report::ProgramManagerWeeklyReportJob
      end
    end
  end
end
