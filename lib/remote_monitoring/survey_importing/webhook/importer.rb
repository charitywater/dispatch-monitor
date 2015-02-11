module RemoteMonitoring
  module SurveyImporting
    module Webhook
      class Importer
        def initialize(
          resolver: FluidSurveys::Structure::Resolver.new,
          survey_importer: nil
        )
          @survey_importer = survey_importer
          @resolver = resolver
        end

        def import(response_hash)
          survey_importer.import(parsed_response(response_hash))
        end

        private

        attr_reader :survey_importer, :resolver

        def parsed_response(response_hash)
          resolver.resolve(response_hash['survey_type']).new(response_hash)
        end
      end
    end
  end
end
