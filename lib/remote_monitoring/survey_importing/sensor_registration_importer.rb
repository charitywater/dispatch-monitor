module RemoteMonitoring
  module SurveyImporting
    class SensorRegistrationImporter
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

        sensor_registration_response = SensorRegistrationResponse.find_or_initialize_by(fs_response_id: parsed_response.fs_response_id)
        sensor_registration_response.update(
          fs_survey_id: parsed_response.fs_survey_id,
          survey_type: parsed_response.survey_type,
          device_number: parsed_response.device_id,
          deployment_code: parsed_response.deployment_code,
          error_code: parsed_response.error_code,
          response: parsed_response.response,
          submitted_at: parsed_response.submitted_at,
        )

        policy = PostProcessor::SensorRegistrationPolicy.new(sensor_registration_response)
        post_processors.each { |p| p.process(policy) }

        sensor_registration_response
      end

      private

      attr_reader :project_importer, :post_processors

      def default_post_processors
        [
          PostProcessor::SensorProjectAssigner.new, #finds or imports the project and creates the sensor
          PostProcessor::SensorStorageClockUpdater.new #gets the timezone offset and packages data to bodytrace to update sensor clock
        ]
      end
    end
  end
end
