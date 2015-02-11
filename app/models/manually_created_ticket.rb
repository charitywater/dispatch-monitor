class ManuallyCreatedTicket < Ticket
  validate :project_has_valid_status
  validate :started_at_is_before_two_years_from_now
  validate :started_at_is_not_in_the_past
  validate :due_at_is_before_two_years_from_now
  validate :due_at_is_not_in_the_past
  validates :project_status,
    presence: true,
    inclusion: { in: %w(needs_maintenance needs_visit) }

  attr_accessor :project_status

  before_create :set_default_due_at
  after_create :update_project_status, :create_manual_activity

  def self.policy_class
    TicketPolicy
  end

  def self.model_name
    Ticket.model_name
  end

  private

  def project_has_valid_status
    unless %i(unknown flowing).include?(project.status.to_sym)
      errors.add(:project, 'must be flowing or unknown')
    end
  end

  def started_at_is_before_two_years_from_now
    if started_at.present? && started_at > (Time.zone.now + 2.years).end_of_day
      errors.add(:started_at, 'must be before two years from now')
    end
  end

  def started_at_is_not_in_the_past
    if started_at.present? && started_at < Time.zone.now.beginning_of_day
      errors.add(:started_at, 'cannot be in the past')
    end
  end

  def due_at_is_before_two_years_from_now
    if due_at.present? && due_at > (Time.zone.now + 2.years).end_of_day
      errors.add(:due_at, 'must be before two years from now')
    end
  end

  def due_at_is_not_in_the_past
    if due_at.present? && due_at < Time.zone.now.beginning_of_day
      errors.add(:due_at, 'cannot be in the past')
    end
  end

  def update_project_status
    project.update(status: project_status)
  end

  def create_manual_activity
    project.activities.status_changed.create(
      happened_at: Time.zone.now,
      data: { status: Project.statuses[project_status] },
      manually_created_by: manually_created_by,
    )
  end

  def set_default_due_at
    if due_at.blank? && project_status == 'needs_maintenance'
      self.due_at = started_at + 30.days
    end
  end
end
