module Email
  module Import
    class MaintenanceReportsJob < BaseJob
      def self.email(data_id)
        job_data = JobData.find(data_id)
        ::Import::MaintenanceReportMailer.results(job_data.data).tap do |_|
          job_data.destroy
        end
      end
    end
  end
end
