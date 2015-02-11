module FluidSurveys
  module Structure
    class MaintenanceReportV02 < Base
      include DeploymentCodeV02

      def self.survey_id
        57040
      end

      def self.survey_type
        :maintenance_report_v02
      end

      def repairs_successful?
        response[keys[:repairs_successful]] == 'Yes'
      end

      def now_inactive?
        [
          'Complete rehabilitation is needed',
          'Depletion of water table',
          'Water point was abandoned',
          'Water point is not accessible due to political strife/war',
          'Water is contaminated',
        ].include?(response[keys[:unsuccessful_repair_reason]])
      end

      private

      def keys
        {
          deployment_code_country: 'rXB5grAKHT_0',
          deployment_code_partner: 'rXB5grAKHT_1',
          deployment_code_quarter: 'rXB5grAKHT_2',
          deployment_code_year: 'rXB5grAKHT_3',
          deployment_code_grant: 'rXB5grAKHT_4',
          deployment_code_point: 'rXB5grAKHT_5',
          deployment_code_optional: 'rXB5grAKHT_6',
          consumable_water: 'JkuCA9JrTB',
          flowing_water: 'JOtRvhF37z',
          fs_response_id: '_id',
          inventory_type: 'HOUKL73PP6',
          maintenance_visit: 'gshGGAKc8i',
          notes: '0nEsoTSiSN',
          repairs_successful: '6yIG9h9Lqk',
          unsuccessful_repair_reason: 'J390tGE6go',
          submitted_at: '_created_at',
        }
      end
    end
  end
end
