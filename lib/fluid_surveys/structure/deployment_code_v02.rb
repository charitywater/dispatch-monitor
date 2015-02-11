module FluidSurveys
  module Structure
    module DeploymentCodeV02
      def deployment_code
        pieces = [
          response[keys[:deployment_code_country]],
          response[keys[:deployment_code_partner]],
          response[keys[:deployment_code_quarter]],
          response[keys[:deployment_code_year]],
          response[keys[:deployment_code_grant]],
          response[keys[:deployment_code_point]],
        ]

        pieces << deployment_code_optional if deployment_code_optional?
        pieces.join('.')
      end

      private

      def deployment_code_optional
        response[keys[:deployment_code_optional]]
      end

      def deployment_code_optional?
        (deployment_code_optional == '000' || deployment_code_optional.nil?) ? false : true
      end
    end
  end
end
