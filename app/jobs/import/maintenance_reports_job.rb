module Import
  class MaintenanceReportsJob < BulkJob
    def self.import(survey_types)
      Array(survey_types).map { |t| importer.import(t) }
    end

    def self.importer
      RemoteMonitoring::SurveyImporting::MaintenanceReportsImporter.new
    end

    def self.email_job
      Email::Import::MaintenanceReportsJob
    end
  end
end
