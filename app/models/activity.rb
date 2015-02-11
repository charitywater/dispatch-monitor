class Activity < ActiveRecord::Base
  has_paper_trail

  belongs_to :project
  belongs_to :manually_created_by, class_name: 'Account'
  belongs_to :sensor

  enum activity_type: {
    completed_construction: 0,
    observation_survey_received: 1,
    maintenance_report_received: 2,
    status_changed: 3,
  }

  validates :activity_type, presence: true
  validates :happened_at, presence: true
  validates :project_id, presence: true

  def self.by_fs_survey_id(fs_survey_id)
    where("data->>'fs_survey_id' = ?", fs_survey_id.to_s)
  end

  def self.by_fs_response_id(fs_response_id)
    where("data->>'fs_response_id' = ?", fs_response_id.to_s)
  end

  def self.status_changed_to_needs_maintenance
    status_changed_to(:needs_maintenance)
  end

  def self.status_changed_to_flowing
    status_changed_to(:flowing)
  end

  def self.status_changed_to_inactive
    status_changed_to(:inactive)
  end

  def self.status_changed_to_needs_visit
    status_changed_to(:needs_visit)
  end

  def self.status_changed_to(status)
    status_changed.where("data->>'status' = ?", Project.statuses[status].to_s)
  end

  def self.manually_created
    where.not(manually_created_by: nil)
  end

  def generated_by_sensor?
    sensor_id.present?
  end
end
