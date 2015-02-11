module RemoteMonitoring
  module PostProcessor
    class TicketCompleter
      def process(policy)
        return unless policy.complete_previous_tickets?

        project = policy.project

        date_boundary = policy.happened_at + 30.minutes

        project
          .tickets
          .incomplete
          .where('started_at < ?', date_boundary)
          .each do |t|
          t.update(
            status: :complete,
            completed_at: policy.happened_at
          )
        end
      end
    end
  end
end
