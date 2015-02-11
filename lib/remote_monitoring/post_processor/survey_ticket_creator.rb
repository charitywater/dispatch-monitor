module RemoteMonitoring
  module PostProcessor
    class SurveyTicketCreator
      def process(policy)
        return unless policy.create_new_ticket?

        survey_response = policy.survey_response

        ticket = Ticket.find_or_initialize_by(survey_response_id: survey_response.id)
        return unless ticket.new_record?

        ticket_params = {
          survey_response: survey_response,
          status: :in_progress,
          started_at: survey_response.submitted_at,
          due_at: nil,
        }

        if policy.ticket_has_due_date?
          ticket_params[:due_at] = survey_response.submitted_at + 30.days
        end

        ticket.update(ticket_params)
      end
    end
  end
end
