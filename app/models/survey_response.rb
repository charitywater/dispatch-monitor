class SurveyResponse < ActiveRecord::Base
  has_paper_trail

  belongs_to :project
  has_one :ticket, dependent: :destroy

  validates :fs_survey_id, presence: true
  validates :fs_response_id, presence: true
  validates :submitted_at, presence: true
  validates :project_id, presence: true
  validates :response, presence: true
  validates :survey_type, presence: true
  validate :allowed_survey_type

  scope :since, ->(time) { where('submitted_at >= ?', time) }

  def self.all_types
    source_observation_types + maintenance_report_types
  end

  def self.source_observation
    where(survey_type: source_observation_types)
  end

  def self.source_observation_types
    [
      :source_observation_v1,
      :source_observation_v02,
      :test_source_observation_v1,
      :test_source_observation_v02,
    ]
  end

  def self.maintenance_report
    where(survey_type: maintenance_report_types)
  end

  def self.maintenance_report_types
    [
      :maintenance_report_v02,
      :test_maintenance_report_v02,
    ]
  end

  def fluid_surveys_url
    @fluid_surveys_url ||= self.class.fluid_surveys_url(fs_survey_id, fs_response_id)
  end

  def source_observation?
    self.class.source_observation_types.include?(survey_type.try(:to_sym))
  end

  def maintenance_report?
    self.class.maintenance_report_types.include?(survey_type.try(:to_sym))
  end

  def flowing_water_answer
    structure.try(:flowing_water)
  end

  def consumable_water_answer
    structure.try(:consumable_water)
  end

  def maintenance_visit_answer
    structure.try(:maintenance_visit)
  end

  def notes
    structure.try(:notes)
  end

  def self.fluid_surveys_url(fs_survey_id, fs_response_id)
    "https://charitywater.fluidsurveys.com/account/surveys/#{fs_survey_id}/responses/?response=#{fs_response_id}"
  end

  def structure
    @structure ||= resolver.resolve(survey_type).new(response)
  end

  private

  def resolver
    FluidSurveys::Structure::Resolver.new
  end

  def allowed_survey_type
    unless source_observation? || maintenance_report?
      errors.add(:survey_type, 'must be a valid type')
    end
  end
end
