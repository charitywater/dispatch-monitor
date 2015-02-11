module RemoteMonitoring
  module PostProcessor
    class SensorTicketCreator
      def process(policy)
        return unless policy.create_new_ticket?

        ticket_params = {
          weekly_log: policy.weekly_log,
          status: :in_progress,
          started_at: policy.happened_at,
          flowing_water_answer: policy.flowing_water_answer,
          maintenance_visit_answer: policy.maintenance_visit_answer,
          due_at: nil,
        }

        if policy.ticket_has_due_date?
          ticket_params[:due_at] = policy.happened_at + 30.days
        end

        Ticket.create(ticket_params)
      end
    end
  end
end
