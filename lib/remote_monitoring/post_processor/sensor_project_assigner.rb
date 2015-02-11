module RemoteMonitoring
  module PostProcessor
    class SensorProjectAssigner
      def process(policy)
        return unless policy.assign_sensor?

        project = Project.find_by(deployment_code: policy.deployment_code)
        project ||= import_project(policy)
        return unless project

        Rails.logger.info(<<-LOG.strip_heredoc)
          Searching spreadsheet...
        LOG

        mapping = CSV.read("#{Rails.root}/lib/assets/sensormapping.csv", :encoding => 'windows-1251:utf-8')
        mapping.shift
        imei = mapping.select { |e| e.include?(policy.device_number) }.first[1].strip

        Rails.logger.info(<<-LOG.strip_heredoc)
          Found IMEI in spreadsheet: #{imei}
        LOG

        sensor = Sensor.find_by(imei: imei)
        return unless sensor

        sensor.update(project: project, device_id: policy.device_number)

        Rails.logger.info(<<-LOG.strip_heredoc)
          Assigned sensor #{sensor.id} to project #{project.id}
        LOG
      end

      private

      def import_project(policy)
        begin
          wazi_importer = WaziImporting::Importer.new
          wazi_importer.import(deployment_code: policy.deployment_code)
          project = Project.find_by(deployment_code: policy.deployment_code)

          unless project
            Rails.logger.info(<<-LOG.strip_heredoc)
              Could not find a project for:
                deployment_code: #{policy.deployment_code}
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