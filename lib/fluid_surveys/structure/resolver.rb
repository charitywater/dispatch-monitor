module FluidSurveys
  module Structure
    class Resolver
      def resolve(survey_type)
        type_to_class_map[survey_type.to_sym]
      end

      private

      def type_to_class_map
        @type_to_class_map ||= [
          FluidSurveys::Structure::SourceObservationV1,
          FluidSurveys::Structure::SourceObservationV02,
          FluidSurveys::Structure::MaintenanceReportV02,
          FluidSurveys::Structure::TestSourceObservationV1,
          FluidSurveys::Structure::TestSourceObservationV02,
          FluidSurveys::Structure::TestMaintenanceReportV02,
          FluidSurveys::Structure::SensorRegistrationAFD1,
          FluidSurveys::Structure::TestSensorRegistrationAFD1,
        ].map do |structure|
          [structure.survey_type, structure]
        end.to_h
      end
    end
  end
end
