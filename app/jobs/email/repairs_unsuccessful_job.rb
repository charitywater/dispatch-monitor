module Email
  class RepairsUnsuccessfulJob < BaseJob
    def self.email(survey_response_id)
      ProjectMailer.repairs_unsuccessful(survey_response_id)
    end
  end
end
