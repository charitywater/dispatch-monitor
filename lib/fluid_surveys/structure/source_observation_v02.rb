module FluidSurveys
  module Structure
    class SourceObservationV02 < Base
      include DeploymentCodeV02

      def self.survey_id
        68483
      end

      def self.survey_type
        :source_observation_v02
      end

      private

      def keys
        {
          deployment_code_country: 'icJ0bt2hs1_0',
          deployment_code_partner: 'icJ0bt2hs1_1',
          deployment_code_quarter: 'icJ0bt2hs1_2',
          deployment_code_year: 'icJ0bt2hs1_3',
          deployment_code_grant: 'icJ0bt2hs1_4',
          deployment_code_point: 'icJ0bt2hs1_5',
          deployment_code_optional: 'icJ0bt2hs1_6',
          consumable_water: '5pXGXZwpaI',
          flowing_water: 'PV5RcUw2ys',
          fs_response_id: '_id',
          inventory_type: 'XBriGBeCyP',
          maintenance_visit: 'LkUlwEuUwP',
          notes: '8Fxk9mToOG',
          submitted_at: '_created_at',
        }
      end
    end
  end
end
