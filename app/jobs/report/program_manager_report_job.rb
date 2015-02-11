module Report
  class ProgramManagerReportJob < Job
    def self.queue
      :report
    end

    def self.perform
      Account.where(role: 1).each do |account|
        if account.weekly_subscription?
          results = report_data(account.program)

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
