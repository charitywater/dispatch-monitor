class ManuallyCompletedTicket < Ticket
  validate :project_has_valid_status
  validates :project_status,
    presence: true,
    inclusion: { in: %w(flowing inactive) }

  attr_accessor :project_status

  after_update :update_project_status, :create_manual_activity

  def update(params)
    unless complete?
      super(params.merge(
        status: :complete,
        completed_at: Time.zone.now,
      ))
    end
  end

  def self.policy_class
    TicketPolicy
  end

  private

  def update_project_status
    project.update(status: project_status)
  end

  def create_manual_activity
    project.activities.status_changed.create(
      happened_at: Time.zone.now,
      data: { status: Project.statuses[project_status] },
      manually_created_by: manually_completed_by,
    )
  end

  def project_has_valid_status
    unless %w(needs_maintenance needs_visit).include?(project.status)
      errors.add(:project, 'must be needs maintenance or needs visit')
    end
  end
end
