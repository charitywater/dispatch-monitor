module RemoteMonitoring
  module SurveyImporting
    class SourceObservationImporter
      def initialize(
        project_importer: RemoteMonitoring::SurveyImporting::ProjectImporter.new,
        post_processors: default_post_processors
      )
        @project_importer = project_importer
        @post_processors = post_processors
      end

      def import(parsed_response)
        return unless parsed_response.valid?

        project = project_importer.import(parsed_response)
        return unless project

        survey_response = SurveyResponse.find_or_initialize_by(fs_response_id: parsed_response.fs_response_id)
        survey_response.update(
          fs_survey_id: parsed_response.fs_survey_id,
          project: project,
          survey_type: parsed_response.survey_type,
          response: parsed_response.response,
          submitted_at: parsed_response.submitted_at,
        )

        policy = PostProcessor::SurveyPolicy.new(survey_response)
        post_processors.each { |p| p.process(policy) }

        survey_response
      end

      private

      attr_reader :project_importer, :post_processors

      def default_post_processors
        [
          PostProcessor::ProjectUpdater.new,
          PostProcessor::ObservationSurveyActivityCreator.new,
          PostProcessor::ProjectStatusActivityCreator.new,
          PostProcessor::SurveyTicketCreator.new,
          PostProcessor::NeedsMaintenanceEmailSender.new
        ]
      end
    end
  end
end
