module RemoteMonitoring
  module WaziImporting
    class Importer
      def initialize(client: Wazi::Client.new, project_importer: WaziImporting::Project.new)
        @client = client
        @project_importer = project_importer
      end

      def import(query_params)
        result = {
          created: Set.new,
          updated: Set.new,
          invalid: Set.new,
        }

        query_params.each do |key, values|
          Array(values).each do |value|
            wazi_projects = client.projects(key => value)

            if wazi_projects.blank?
              result[:invalid] << value
            else
              wazi_projects.each do |wazi_project|
                project = project_importer.import(wazi_project)

                if project.nil?
                  result[:invalid] << value
                else
                  model_status = project.previous_changes.key?(:id) ? :created : :updated
                  result[model_status] << wazi_project['deployment_code']
                end
              end
            end
          end
        end

        result
      end

      private

      attr_reader :client, :project_importer
    end
  end
end
