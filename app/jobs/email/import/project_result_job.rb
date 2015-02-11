module Email
  module Import
    class ProjectResultJob < BaseJob
      def self.email(data_id)
        job_data = JobData.find(data_id)
        ::Import::ProjectMailer.results(job_data.data).tap do |_|
          job_data.destroy
        end
      end
    end
  end
end
