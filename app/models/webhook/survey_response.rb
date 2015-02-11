module Webhook
  class SurveyResponse
    def initialize(params)
      @params = params
    end

    def survey_type
      params[:survey_type]
    end

    def save
      if source_observation?
        enqueue(Import::SourceObservationJob, params)
      elsif sensor_registration?
        enqueue(Import::SensorRegistrationJob, params)
      elsif maintenance_report?
        enqueue_in(30.minutes, Import::MaintenanceReportJob, params)
      end
    end

    private

    attr_reader :params

    def enqueue(*args)
      RemoteMonitoring::JobQueue.enqueue(*args)
    end

    def enqueue_in(*args)
      RemoteMonitoring::JobQueue.enqueue_in(*args)
    end

    def source_observation?
      ::SurveyResponse.source_observation_types.include?(survey_type.to_sym)
    end

    def maintenance_report?
      ::SurveyResponse.maintenance_report_types.include?(survey_type.to_sym)
    end

    def sensor_registration?
      ::SensorRegistrationResponse.sensor_registration_types.include?(survey_type.to_sym)
    end
  end
end
