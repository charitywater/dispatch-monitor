module RemoteMonitoring
  module SurveyImporting
    class SourceObservationsImporter
      def initialize(
        client: FluidSurveys::Client.new,
        survey_importer: SourceObservationImporter.new,
        resolver: FluidSurveys::Structure::Resolver.new
      )
        @client = client
        @survey_importer = survey_importer
        @resolver = resolver
      end

      def import(survey_type)
        result = {
          survey_type: survey_type,
          created: [],
          invalid: [],
          updated: [],
        }

        survey_structure = resolver.resolve(survey_type)

        client.responses(survey_structure.survey_id).each do |r|
          parsed_response = survey_structure.new(r)
          survey_response = survey_importer.import(parsed_response)

          result[model_status_for(survey_response)] << {
            fs_survey_id: parsed_response.fs_survey_id,
            fs_response_id: parsed_response.fs_response_id,
            deployment_code: parsed_response.deployment_code,
          }
        end

        Rails.logger.info(<<-LOG.strip_heredoc)
          The following survey response IDs were invalid:
            #{result[:invalid].map { |r| "#{r.map { |k, v| "#{k}: #{v}" }.join(' ')}--" }.join("\n            ")}
        LOG
        result
      end

      private

      attr_reader :client, :survey_importer, :resolver

      def model_status_for(survey_response)
        if survey_response
          survey_response.previous_changes.key?(:id) ? :created : :updated
        else
          :invalid
        end
      end
    end
  end
end
