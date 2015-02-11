module Map
  class TicketsController < ApplicationController
    def index
      project = Project.find(params[:project_id])
      authorize project, :show?

      project = ProjectPresenter.new(project)

      tickets = ticket_query
        .result(project.tickets)
        .includes(:manually_created_by, :manually_completed_by)
        .map { |ticket| TicketPresenter.new(ticket) }

      render json: {
        tickets: tickets,
        allows_new_ticket: project.allows_new_ticket? && !current_account.viewer?,
        project_id: project.id
      }
    end

    private

    def ticket_query
      CompositeQuery.new(
        Tickets::NonDeletedQuery.new,
        Tickets::OrderedQuery.new,
      )
    end
  end
end
