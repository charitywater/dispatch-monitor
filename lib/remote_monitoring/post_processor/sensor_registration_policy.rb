module RemoteMonitoring
  module PostProcessor
    class SensorRegistrationPolicy
      attr_reader :survey_response

      def initialize(survey_response)
        @survey_response = survey_response
      end

      def device_number
        survey_response.device_number
      end

      def happened_at
        survey_response.submitted_at
      end

      def deployment_code
        survey_response.deployment_code
      end

      def valid_deployment_code?
        deployment_code.match(RemoteMonitoring::Constants.deployment_code_regex).nil? ? false : true
      end

      def spreadsheet
        File.exist?(Rails.root + 'lib/assets/sensormapping.csv')
      end

      def spreadsheet_exists?
        spreadsheet ? true : false
      end

      def assign_sensor?
        valid_deployment_code? && spreadsheet_exists? && !network_error?
      end

      def error_code
        survey_response.error_code
      end

      def network_error?
        (error_code.downcase.to_sym == :oh) ? false : true
      end
    end
  end
end
