module RemoteMonitoring
  module SurveyImporting
    class ProjectImporter
      def initialize(wazi_importer: WaziImporting::Importer.new)
        @wazi_importer = wazi_importer
      end

      def import(parsed_response)
        project = Project.find_by(
          deployment_code: parsed_response.deployment_code
        )
        project ||= import_project(parsed_response)

        if project
          project.update(inventory_type: parsed_response.inventory_type)
        else
          Rails.logger.info(<<-LOG.strip_heredoc)
            Could not find a project for:
              survey: #{parsed_response.fs_survey_id}
              response: #{parsed_response.fs_response_id}
              deployment_code: #{parsed_response.deployment_code}
          LOG
        end

        project
      end

      private

      attr_reader :wazi_importer

      def import_project(parsed_response)
        begin
          wazi_importer.import(deployment_code: parsed_response.deployment_code)
          project = Project.find_by(deployment_code: parsed_response.deployment_code)

          unless project
            Rails.logger.info(<<-LOG.strip_heredoc)
              Could not find a project for:
                survey: #{parsed_response.fs_survey_id}
                response: #{parsed_response.fs_response_id}
                deployment_code: #{parsed_response.deployment_code}
            LOG
          end
        rescue URI::InvalidURIError => e
          ErrorNotifier.notify(e)
        end

        project
      end
    end
  end
end
