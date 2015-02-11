module FluidSurveys
  module Structure
    class Base
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def fs_survey_id
        self.class.survey_id
      end

      def from_webhook?
        response.key?('webhook')
      end

      def fs_response_id
        response[keys[:fs_response_id]]
      end

      def survey_type
        self.class.survey_type
      end

      def valid?
        deployment_code.present? && deployment_code.match(RemoteMonitoring::Constants.deployment_code_regex)
      end

      def status
        if flowing_water == 'No'
          :needs_maintenance
        elsif flowing_water == 'Unable to Access'
          :needs_visit
        elsif flowing_water == 'Yes'
          if consumable_water == 'No'
            :needs_visit
          elsif consumable_water == 'Unknown / Unable to Answer'
            :needs_visit
          elsif consumable_water == 'Yes'
            if maintenance_visit == 'Yes'
              :needs_visit
            elsif maintenance_visit == 'No'
              :flowing
            end
          end
        end
      end

      def flowing_water
        response[keys[:flowing_water]]
      end

      def maintenance_visit
        response[keys[:maintenance_visit]]
      end

      def consumable_water
        response[keys[:consumable_water]]
      end

      def notes
        response[keys[:notes]]
      end

      def inventory_type
        response[keys[:inventory_type]]
      end

      def submitted_at
        strip_milliseconds(response[keys[:submitted_at]])
      end

      private

      def strip_milliseconds(time)
        Time.at(
          Time.zone.parse(time).to_i
        ).to_datetime
      end
    end
  end
end
