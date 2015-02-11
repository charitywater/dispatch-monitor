module FluidSurveys
  module Structure
    class SensorRegistrationAFD1 < Base
      include DeploymentCodeV02

      # http://charitywater.fluidsurveys.com/api/v2/surveys/85707/responses/
      def self.survey_id
        85707
      end

      def self.survey_type
        :sensor_registration_afd1
      end

      def device_id
        response[keys[:device_id]].strip
      end

      def error_code
        response[keys[:error_code]].strip
      end

      def valid?
        true
      end

      private

      def keys
        {
          fs_response_id: '_id',
          fs_survey_id: 'survey_id',
          submitted_at: '_created_at',
          device_id: 'CFDuMWqytJ',
          deployment_code_country: 'TBLwLK3wL8_0',
          deployment_code_partner: 'TBLwLK3wL8_1',
          deployment_code_quarter: 'TBLwLK3wL8_2',
          deployment_code_year: 'TBLwLK3wL8_3',
          deployment_code_grant: 'TBLwLK3wL8_4',
          deployment_code_point: 'TBLwLK3wL8_5',
          error_code: '0oLTpi9Goh'
        }
      end
    end
  end
end
