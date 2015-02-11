class Dashboard
  attr_reader :filter_form

  delegate :program, :bounds, to: :filter_form

  def initialize(filter_form)
    @filter_form = filter_form
  end

  delegate :name, to: :program, prefix: true

  def total_project_count
    @total_project_count ||= program.projects.count
  end

  def flowing_project_count
    @flowing_project_count ||= program.projects.flowing.count
  end

  def needs_maintenance_project_count
    @needs_maintenance_project_count ||= program.projects.needs_maintenance.count
  end

  def inactive_project_count
    @inactive_project_count ||= program.projects.inactive.count
  end

  def unknown_project_count
    @unknown_project_count ||= program.projects.unknown.count
  end

  def needs_visit_project_count
    @needs_visit_project_count ||= program.projects.needs_visit.count
  end

  def total_survey_response_count
    @total_survey_response_count ||= recent_survey_responses.count
  end

  def source_observation_survey_response_count
    @source_observation_survey_response_count ||=
      recent_survey_responses.source_observation.count
  end

  def maintenance_report_survey_response_count
    @maintenance_report_survey_response_count ||=
      recent_survey_responses.maintenance_report.count
  end

  def incomplete_ticket_count
    @incomplete_ticket_count ||= program.tickets.non_deleted.incomplete.count
  end

  def due_soon_ticket_count
    @due_soon_ticket_count ||= program.tickets.non_deleted.due_soon.count
  end

  def overdue_ticket_count
    @overdue_ticket_count ||= program.tickets.non_deleted.overdue.count
  end

  private

  def recent_survey_responses
    program.survey_responses.since(filter_form.since)
  end
end
