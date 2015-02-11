class SensorRegistrationResponse < ActiveRecord::Base
  has_paper_trail

  scope :since, ->(time) { where('submitted_at >= ?', time) }

  def self.sensor_registration
    where(survey_type: sensor_registration_types)
  end

  def self.sensor_registration_types
    [
      :sensor_registration_afd1,
      :test_sensor_registration_afd1
    ]
  end

  def fluid_surveys_url
    @fluid_surveys_url ||= self.class.fluid_surveys_url(fs_survey_id, fs_response_id)
  end

  def sensor_registration?
    self.class.sensor_registration_types.include?(survey_type.try(:to_sym))
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

  # def allowed_survey_type
  #   unless sensor_registration?
  #     errors.add(:survey_type, 'must be a valid type')
  #   end
  # end
end
