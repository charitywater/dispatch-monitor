class Ticket < ActiveRecord::Base
  has_paper_trail

  belongs_to :project
  belongs_to :survey_response
  belongs_to :weekly_log
  belongs_to :manually_created_by, class_name: 'Account'
  belongs_to :manually_completed_by, class_name: 'Account'
  has_one :program, through: :project

  enum status: {
    in_progress: 0,
    complete: 1,
  }

  validates :started_at, presence: true
  validates :status, presence: true
  validates :project_id, presence: true
  validate :due_at_is_after_started_at

  delegate :community_name, :deployment_code, to: :project

  scope :non_deleted, -> { where(deleted_at: nil) }
  scope :deleted, -> { where('deleted_at IS NOT NULL') }

  def self.in_progress
    where(status: Ticket.statuses[:in_progress])
      .where('due_at >= ? OR due_at IS NULL', Time.zone.now.beginning_of_day)
  end

  def self.overdue
    where(status: Ticket.statuses[:in_progress])
      .where('due_at < ?', Time.zone.now.beginning_of_day)
  end

  def self.incomplete
    where(status: Ticket.statuses[:in_progress])
  end

  def self.due_soon
    in_progress.where('due_at <= ?', (Time.zone.now + 7.days).end_of_day)
  end

  class << self
    alias_method :old_statuses, :statuses

    def statuses
      @statuses ||= old_statuses.merge(overdue: 2)
    end
  end

  def soft_delete
    touch(:deleted_at)
  end

  def status
    if super == 'in_progress' && due_before_today?
      'overdue'
    else
      super
    end
  end

  def overdue?
    status == 'overdue'
  end

  def survey_response=(survey_response)
    super
    self.project = survey_response.project
  end

  def weekly_log=(weekly_log)
    super
    self.project = weekly_log.project
  end

  private

  def due_before_today?
    due_at && due_at < Time.zone.now.beginning_of_day
  end

  def due_at_is_after_started_at
    if due_at.present? && started_at.present? && due_at < started_at
      errors.add(:due_at, 'must be after the Ticket’s start date')
    end
  end
end
