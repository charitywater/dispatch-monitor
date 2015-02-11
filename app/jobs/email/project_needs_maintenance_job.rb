module Email
  class ProjectNeedsMaintenanceJob < BaseJob
    def self.email(survey_response_id)
      ProjectMailer.needs_maintenance(survey_response_id)
    end
  end
end
