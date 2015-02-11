module RemoteMonitoring
  module SurveyImporting
    class Remover
      attr_reader :client

      def initialize(client = FluidSurveys::Client.new)
        @client = client
      end

      def remove_deleted
        SurveyResponse.find_each do |s|
          data = {
            fs_survey_id: s.fs_survey_id,
            fs_response_id: s.fs_response_id,
          }

          unless client.survey_response(data)
            Activity.observation_survey_received
              .by_fs_survey_id(s.fs_survey_id)
              .by_fs_response_id(s.fs_response_id)
              .destroy_all

            s.destroy
          end
        end
      end
    end
  end
end
