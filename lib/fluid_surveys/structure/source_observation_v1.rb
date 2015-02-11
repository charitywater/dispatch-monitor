module FluidSurveys
  module Structure
    class SourceObservationV1 < Base
      def self.survey_id
        51399
      end

      def self.survey_type
        :source_observation_v1
      end

      def deployment_code
        response[keys[:deployment_code]].strip
      end

      private

      def consumable_water
        'Yes'
      end

      def keys
        {
          deployment_code: 'icJ0bt2hs1',
          flowing_water: 'qVreqGQpLA',
          fs_response_id: '_id',
          fs_survey_id: 'survey_id',
          inventory_type: 'EbwEfSdETT',
          maintenance_visit: 'hqSVwuhttr',
          notes: 'oDqhgFtgGQ',
          submitted_at: '_created_at',
        }
      end
    end
  end
end
