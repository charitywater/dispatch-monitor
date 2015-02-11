module RemoteMonitoring
  module SurveyImporting
    class MaintenanceReportsImporter
      def initialize(client: FluidSurveys::Client.new, survey_importer: MaintenanceReportImporter.new, resolver: FluidSurveys::Structure::Resolver.new)
        @client = client
        @survey_importer = survey_importer
        @resolver = resolver
      end

      def import(survey_type)
        result = {
          survey_type: survey_type,
          complete: [],
          incomplete: [],
          invalid: [],
          inactive: [],
        }

        survey_structure = resolver.resolve(survey_type)

        client.responses(survey_structure.survey_id).each do |r|
          parsed_response = survey_structure.new(r)
          survey_importer.import(parsed_response)

          statuses_for(parsed_response).each do |status|
            result[status] << {
              fs_survey_id: parsed_response.fs_survey_id,
              fs_response_id: parsed_response.fs_response_id,
              deployment_code: parsed_response.deployment_code,
            }
          end
        end

        result
      end

      private

      attr_reader :client, :survey_importer, :resolver

      def statuses_for(parsed_response)
        statuses = []

        if parsed_response.valid?
          statuses << :inactive if parsed_response.now_inactive?
          if parsed_response.repairs_successful?
            statuses << :complete
          else
            statuses << :incomplete
          end
        else
          statuses << :invalid
        end
      end
    end
  end
end
