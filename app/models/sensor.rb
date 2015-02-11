class Sensor < ActiveRecord::Base
  has_paper_trail

  belongs_to :project
  has_many :weekly_logs, dependent: :destroy

  validates :imei,
    uniqueness: true,
    presence: true

  delegate :deployment_code, :community_name, to: :project
end
