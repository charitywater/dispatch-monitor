module Report
  class AdminReportJob < Job
    def self.queue
      :report
    end

    def self.perform
      results = report_data

      Account.where(role: "admin").each do |account|
        if account.weekly_subscription?
          job_data = JobData.create(
            data: { results: results, recipient_id: account.id }
          )
          enqueue(email_job, job_data.id)
        end
      end
    end

    def self.after_perform(*args); end
  end
end
