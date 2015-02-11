module Import
  class Survey
    include ActiveModel::Model

    attr_accessor :survey_type

    validates :survey_type, inclusion: { in: SurveyResponse.all_types.map(&:to_s) }

    def save
      if valid?
        if source_observation?
          enqueue(SourceObservationsJob, survey_type)
        elsif maintenance_report?
          enqueue(MaintenanceReportsJob, survey_type)
        end
      end

      valid?
    end

    private

    def enqueue(*args)
      RemoteMonitoring::JobQueue.enqueue(*args)
    end

    def source_observation?
      ::SurveyResponse.source_observation_types.include?(survey_type.to_sym)
    end

    def maintenance_report?
      ::SurveyResponse.maintenance_report_types.include?(survey_type.to_sym)
    end
  end
end
