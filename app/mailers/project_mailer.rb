class ProjectMailer < Mailer
  def needs_maintenance(survey_response_id)
    @survey_response = SurveyResponse.find(survey_response_id)
    @project = @survey_response.project

    mail(subject: "#{@project.community_name} (#{@project.deployment_code}) needs maintenance")
  end

  def repairs_unsuccessful(survey_response_id)
    @survey_response = SurveyResponse.find(survey_response_id)
    @project = @survey_response.project

    mail(subject: "Repairs at #{@project.community_name} (#{@project.deployment_code}) were unsuccessful")
  end
end
