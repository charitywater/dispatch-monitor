module Email
  module Import
    class SourceObservationsJob < BaseJob
      def self.email(data_id)
        job_data = JobData.find(data_id)
        ::Import::SourceObservationMailer.results(job_data.data).tap do |_|
          job_data.destroy
        end
      end
    end
  end
end
