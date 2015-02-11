module RemoteMonitoring
  module SurveyImporting
    class MaintenanceReportImporter
      def initialize(post_processors = default_post_processors)
        @post_processors = post_processors
      end

      def import(parsed_response)
        return unless parsed_response.valid?

        project = Project.find_by(deployment_code: parsed_response.deployment_code)
        return unless project

        survey_response = SurveyResponse.find_or_initialize_by(fs_response_id: parsed_response.fs_response_id)
        survey_response.update(
          project_id: project.id,
          fs_survey_id: parsed_response.fs_survey_id,
          survey_type: parsed_response.survey_type,
          response: parsed_response.response,
          submitted_at: parsed_response.submitted_at,
        )

        policy = PostProcessor::SurveyPolicy.new(survey_response)
        post_processors.each { |p| p.process(policy) }

        survey_response
      end

      private

      attr_reader :post_processors

      def default_post_processors
        # order matters
        [
          PostProcessor::ProjectUpdater.new,
          PostProcessor::TicketCompleter.new,
          PostProcessor::MaintenanceReportActivityCreator.new,
          PostProcessor::ProjectStatusActivityCreator.new,
          PostProcessor::SurveyTicketCreator.new,
          PostProcessor::NeedsMaintenanceEmailSender.new,
          PostProcessor::RepairsUnsuccessfulEmailSender.new,
        ]
      end
    end
  end
end
