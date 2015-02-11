class TicketsController < ApplicationController
  def index
    @tickets = TicketList.new(FilterForm.new(filter_params))
  end

  def show
    authorize ticket, :show?
    @ticket = TicketPresenter.new(ticket)
  end

  def new
    project = Project.find(params[:project_id])
    ticket = ManuallyCreatedTicket.new(project: project)
    authorize ticket, :create?

    @ticket = TicketPresenter.new(ticket)
  end

  def create
    ticket = ManuallyCreatedTicket.new(create_ticket_params)
    authorize ticket, :create?

    if ticket.save
      redirect_to ticket_path(ticket),
        success: t('.success', id: ticket.id)
    else
      @ticket = TicketPresenter.new(ticket)
      flash.now[:alert] = t('.alert')
      render :new
    end
  end

  def complete
    ticket = ManuallyCompletedTicket.find(params[:id])
    authorize ticket, :update?

    if ticket.update(complete_ticket_params)
      redirect_to ticket_path(ticket),
        success: t(
          '.success',
          id: ticket.id,
          deployment_code: ticket.deployment_code,
          community_name: ticket.community_name,
          project_status: ticket.project_status,
      )
    else
      render status: :unprocessable_entity, nothing: true
    end
  end

  def destroy
    authorize ticket, :destroy?
    ticket.soft_delete

    redirect_to tickets_path,
      success: t('.success', id: ticket.id)
  end

  private

  def create_ticket_params
    project = Project.find(params[:project_id])

    params.require(:ticket)
      .permit(:started_at, :due_at, :notes, :project_status)
      .merge(
        status: :in_progress,
        project: project,
        manually_created_by: current_account,
      )
  end

  def complete_ticket_params
    params.require(:ticket)
      .permit(:project_status)
      .merge(manually_completed_by: current_account)
  end

  def ticket
    @ticket ||= Ticket.non_deleted.find(params[:id])
  end
end
