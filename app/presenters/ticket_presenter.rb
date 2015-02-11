class TicketPresenter < Presenter
  delegate :country, :contact_name, :contact_email, :contact_phone_numbers,
    to: :project

  def due_at
    ticket.due_at && l(ticket.due_at, format: :date)
  end

  def started_at
    ticket.started_at && l(ticket.started_at, format: :date)
  end

  def completed_at
    ticket.completed_at && l(ticket.completed_at, format: :date)
  end

  def status_tag
    content_tag(:span, status.sub('_', ' ').titleize, class: "ticket-status #{status}")
  end

  def gps
    "#{format(project.latitude)}, #{format(project.longitude)}"
  end

  def project_status_tag
    link_to ticket.project.status.titleize, map_project_path(ticket.project), class: "project-status #{ticket.project.status}"
  end

  def project
    @project ||= ProjectPresenter.new(ticket.project)
  end

  def flowing_water_answer
    answer_tag(
      ticket.flowing_water_answer ||
      survey_response.try(:flowing_water_answer)
    )
  end

  def consumable_water_answer
    answer_tag(
      survey_response.try(:consumable_water_answer)
    )
  end

  def maintenance_visit_answer
    answer_tag(
      ticket.maintenance_visit_answer ||
      survey_response.try(:maintenance_visit_answer),
      negative_classes
    )
  end

  def notes
    ticket.notes.presence || survey_response.try(:notes).presence || 'N/A'
  end

  def manually_created_by
    if ticket.manually_created_by
      AccountPresenter.new(ticket.manually_created_by)
    end
  end

  def manually_completed_by
    if ticket.manually_completed_by
      AccountPresenter.new(ticket.manually_completed_by)
    end
  end

  def as_json(*_args)
    {
      id: id,
      status: status,
      started_at: started_at,
      due_at: due_at,
      completed_at: completed_at,
      manually_created_by: manually_created_by.as_json,
      manually_completed_by: manually_completed_by.as_json,
      generated_by_sensor: weekly_log_id,
    }
  end

  def self.policy_class
    TicketPolicy
  end

  private

  alias_method :ticket, :__getobj__

  def format(float)
    '%.6f' % float
  end

  def answer_tag(answer, classes = positive_classes)
    content_tag(:span, answer || 'N/A', class: classes[answer])
  end

  def positive_classes
    { 'Yes' => 'status positive', 'No' => 'status negative' }
  end

  def negative_classes
    { 'No' => 'status positive', 'Yes' => 'status negative' }
  end
end
