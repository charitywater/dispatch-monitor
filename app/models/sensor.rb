class Sensor < ActiveRecord::Base
  has_paper_trail

  belongs_to :project
  has_many :weekly_logs, dependent: :destroy

  validates :imei,
    uniqueness: true,
    presence: true

  def deployment_code
    self.project.nil? ? nil : self.project.deployment_code
  end

  def community_name
    self.project.nil? ? nil : self.project.community_name
  end
end
