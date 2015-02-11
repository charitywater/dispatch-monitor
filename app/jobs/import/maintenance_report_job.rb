module Import
  class MaintenanceReportJob < Job
    def self.queue
      :import
    end

    def self.perform(params)
      importer.import(params)
    end

    private

    def self.importer
      RemoteMonitoring::SurveyImporting::Webhook::Importer.new(
        survey_importer: RemoteMonitoring::SurveyImporting::MaintenanceReportImporter.new
      )
    end
  end
end
