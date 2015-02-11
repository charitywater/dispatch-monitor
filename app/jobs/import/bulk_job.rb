module Import
  class BulkJob < Job
    def self.queue
      :import
    end

    def self.perform(*args)
      results = import(*args)

      EmailSubscription.bulk_import_notifications.find_each do |subscription|
        job_data = JobData.create(
          data: { results: results, recipient_id: subscription.account_id }
        )
        enqueue(email_job, job_data.id)
      end

      after_perform(*args)
    end

    def self.after_perform(*args); end
  end
end
